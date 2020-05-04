#include "gisfunctions.h"


double latlondist_vincenty(float lat1, float lon1, float lat2, float lon2){

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

        return deg * pi /180;
}

double toDeg(double rad){

        return rad * pi / 180;
}
