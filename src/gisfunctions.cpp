#include "headers/gisfunctions.h"

int indexCoordinate(QVector<trackpoint> &trackpoints, const QGeoCoordinate coordinate, bool insert){

    float distance = 1000000;
    float dx = 0;
    int index = 0;
    float x0 = coordinate.longitude(),
          y0 = coordinate.latitude(),
          x1y1x,
          x1y1y,
          x2y2x,
          x2y2y;

    for(int i = 0; i < trackpoints.count() - 1; i++){
        //Distance from line algorithm
        x1y1x = trackpoints[i].latlon.longitude();
        x1y1y = trackpoints[i].latlon.latitude();
        x2y2x = trackpoints[i+1].latlon.longitude();
        x2y2y = trackpoints[i+1].latlon.longitude();
        dx = abs((((x2y2y - x1y1y) * x0) -((x2y2x - x1y1x) *y0) + (x2y2x * x1y1y) - (x2y2y * x1y1x)) ) /
             sqrt(((x2y2y -x1y1y)*(x2y2y -x1y1y)) +((x2y2x -x1y1x) *(x2y2x -x1y1x)) );

        if(dx < distance){
            distance = dx;
            index = i +1 ;
        }

    }

   if(insert) {
        trackpoint item ={coordinate,0, QDateTime::currentDateTime()};
        trackpoints.insert(index,1,item);
   }
   return index;

}

QVector<trackpoint> addHeight( QVector<trackpoint> trackpointsVectors, const int index, const int limit) {

    //gdal stuff
    GDALDataset *testDataSet;
    GDALRasterBand *heightBand;
    double adfGeoTransform[6] = {};
    double adfInvGeoTransform[6] = {};
    int iPixel, iLine;
    int count = 0;
    double adfPixel[2];

    //Initialise GDAL
    qDebug() << "Initialising GDAL";

    GDALAllRegister();

    const char *pzFileName = nullptr;
    //TODO find a way to do this in qrc file, think it may be impossible
    pzFileName = "/Users/daveb/mapping-data/SRTM/all_uk_data.tif";
    testDataSet =  (GDALDataset *) GDALOpen(pzFileName,GA_ReadOnly);
    heightBand = testDataSet->GetRasterBand(1);
    //Transformers from coordinate to pixel grid
    if( GDALGetGeoTransform( testDataSet, adfGeoTransform ) != CE_None ) {
        CPLError(CE_Failure, CPLE_AppDefined, "Cannot get geotransform");
        exit( 1 );
    }

    if( !GDALInvGeoTransform( adfGeoTransform, adfInvGeoTransform ) ) {
        CPLError(CE_Failure, CPLE_AppDefined, "Cannot invert geotransform");
        exit( 1 );
    }

    qDebug() <<"GDAL ALL DONE READY TO ADD HEIGHT";


    int markers = std::min(trackpointsVectors.count(), index + limit); //make sure we do not overshoot
    if(markers == -1) //-1 sets everything in array
        markers = trackpointsVectors.count();

    for (int i = index; i < markers; i++) {

        iPixel = static_cast<int>(floor(
            adfInvGeoTransform[0]
            + adfInvGeoTransform[1] * trackpointsVectors[i].latlon.longitude()
            + adfInvGeoTransform[2] * trackpointsVectors[i].latlon.latitude()));

        iLine = static_cast<int>(floor(
            adfInvGeoTransform[3]
            + adfInvGeoTransform[4] * trackpointsVectors[i].latlon.longitude()
            + adfInvGeoTransform[5] * trackpointsVectors[i].latlon.latitude()));

        //TODO I need to understand why ! works
        if(!GDALRasterIO( heightBand, GF_Read, iPixel, iLine, 1, 1,adfPixel, 1, 1, GDT_CFloat64, 0, 0)) {
            trackpointsVectors[i].ele = adfPixel[0];
        } else {
            trackpointsVectors[i].ele = 0;
        }


        count++;
    }

    return trackpointsVectors;
}

double latlondist_vincenty(QGeoCoordinate coord1, QGeoCoordinate coord2){

    float lat1 = coord1.latitude(),
          lon1 = coord1.longitude(),
          lat2 = coord2.latitude(),
          lon2 = coord2.longitude();

    double a = 6378137;
    double b = 6356752.314245;
    double f = 1 / 298.257223563;

    double L = toRad((lon2-lon1));
    double U1 = atan((1-f) * tan(toRad(lat1)));
    double U2 = atan((1-f) * tan(toRad(lat2)));
    double sinU1 = sin(U1);
    double cosU1 = cos(U1);
    double sinU2 = sin(U2);
    double cosU2 = cos(U2);

    double lambda = L;
    double lambdaP = 0;
    double iterLimit = 100;

    double cosSqAlpha = 0;
    double cos2SigmaM = 0;
    double sinAlpha = 0;
    double sigma = 0;
    double cosSigma = 0;
    double sinSigma = 0;
    double cosLambda = 0;
    double sinLambda = 0;
    double C = 0;


    do{

        sinLambda = sin(lambda);
        cosLambda = cos(lambda);

        sinSigma = sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda));
        if (sinSigma==0) {
            return 0;  // co-incident points
        }

        cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda;
        sigma = atan2(sinSigma, cosSigma);
        sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
        cosSqAlpha = 1 - sinAlpha*sinAlpha;
        cos2SigmaM = cosSigma - 2*sinU1*sinU2/cosSqAlpha;

        if(cos2SigmaM != cos2SigmaM){
            cos2SigmaM = 0;             //equatorial line
        }

        C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
        lambdaP = lambda;
        lambda = L + (1 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));

    } while(abs(lambda - lambdaP) > 1e-12 && --iterLimit > 0);

    if(iterLimit == 0 ) {
        return 0;           //formula failed to converge
    }

    double uSq = cosSqAlpha * (a*a - b*b) / (b*b);
    double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    double deltaSigma = B * sinSigma * (cos2SigmaM + B/4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - B/6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)));
    double s = b * A * (sigma - deltaSigma);

    return s;
}

double toRad(double deg){

        return deg * 3.14159265358979323846264338327950288419717 /180;
}

double toDeg(double rad){

        return rad * 3.14159265358979323846264338327950288419717 / 180;
}
