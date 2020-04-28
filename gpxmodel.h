#ifndef MAPMARKER_H
#define MAPMARKER_H


#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QDebug>
#include <QDate>
#include <QQuickItem>
#include <QXmlStreamReader>
#include "gdal_priv.h"

struct gpxCoordinate {
    QGeoCoordinate latlon;
    float ele;
    QDateTime time;
    int index;
};

class GPXModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QVariantList path READ path NOTIFY pathChanged)

public:
    enum GPXModelRoles{positionRole = Qt::UserRole, pathRole, itemRole};

    GPXModel(QObject *parent=nullptr): QAbstractListModel(parent)
    {
        connect(this, &QAbstractListModel::rowsInserted, this, &GPXModel::pathChanged);
        connect(this, &QAbstractListModel::rowsRemoved, this, &GPXModel::pathChanged);
        connect(this, &QAbstractListModel::dataChanged, this, &GPXModel::pathChanged);
        connect(this, &QAbstractListModel::modelReset, this, &GPXModel::pathChanged);
        connect(this, &QAbstractListModel::rowsMoved, this, &GPXModel::pathChanged);

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
    }

Q_INVOKABLE int addMarker(const QGeoCoordinate &coordinate, float elevation = -1, QDateTime dateTime = QDateTime::currentDateTime());
Q_INVOKABLE bool loadFromFile(const QUrl fileName);
Q_INVOKABLE bool saveToFile(QUrl filename = QUrl());
Q_INVOKABLE void setEditLocation(const int pathIndex,  int range = -1);
Q_INVOKABLE int addMarkerAtIndex(const QGeoCoordinate &coordinate, int index, float elevation = -1, QDateTime dateTime = QDateTime::currentDateTime());
Q_INVOKABLE QGeoCoordinate deleteMarkerAtIndex(int index);
Q_INVOKABLE QGeoCoordinate updateMarkerLocation(const QGeoCoordinate &coordinate, int index);
Q_INVOKABLE QString getFileName() {  return m_fileName.fileName();};
Q_INVOKABLE void clearMarkers( ){
            beginRemoveRows(QModelIndex(),0,rowCount());
            edit_markers.clear();
            m_coordinates.clear();
            endRemoveRows();
};
    Q_INVOKABLE int setNumDragHandles(int num){
        numDragHandles = num;
        return numDragHandles;
    }

Q_INVOKABLE int addHeightToPath(const int index, const int limit = 1);

int rowCount(const QModelIndex &parent = QModelIndex()) const override;
bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
bool removeRow(int row, const QModelIndex &parent = QModelIndex());
QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
QHash<int, QByteArray> roleNames() const override;
QVariantList path() const;
void reindex(int index);

signals:
    void pathChanged();

private:
    int numDragHandles = 30;
    QVector<gpxCoordinate> m_coordinates;
    QVector<gpxCoordinate> edit_markers;
    QUrl m_fileName;

    //gdal stuff
    GDALDataset *testDataSet;
    GDALRasterBand *heightBand;
    double adfGeoTransform[6] = {};
    double adfInvGeoTransform[6] = {};
};
#endif // GPXModel_H
