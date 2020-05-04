#ifndef MAPMARKER_H
#define MAPMARKER_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QDebug>
#include <QDate>
#include <QQuickItem>
#include <QXmlStreamReader>
#include "gdal_priv.h"
#include "gisfunctions.h"

struct gpxCoordinate {
    QGeoCoordinate latlon;
    float ele;
    QDateTime time;
    int index;
    double distanceFromPrevious;
};

struct waypointMarker {
    QGeoCoordinate latlon;
    QString description;
};

class GPXModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QVariantList path READ path NOTIFY pathChanged)

public:
//Constructor
GPXModel(QObject *parent=nullptr);

//Definition of roles used by QML to access the model
enum GPXModelRoles{positionRole = Qt::UserRole, pathRole, itemRole};

//Externally invokable methods
Q_INVOKABLE int addMarker(const QGeoCoordinate &coordinate, float elevation = -1, QDateTime dateTime = QDateTime::currentDateTime());
Q_INVOKABLE int addMarkerAtIndex(const QGeoCoordinate &coordinate, int index, float elevation = -1, QDateTime dateTime = QDateTime::currentDateTime());
Q_INVOKABLE QGeoCoordinate deleteMarkerAtIndex(int index);
Q_INVOKABLE void clearMarkers( );
Q_INVOKABLE QGeoCoordinate updateMarkerLocation(const QGeoCoordinate &coordinate, int index);
Q_INVOKABLE void setEditLocation(const int pathIndex,  int range = -1);
Q_INVOKABLE int addHeightToPath(const int index, const int limit = 1);
Q_INVOKABLE int setNumDragHandles(int num);
Q_INVOKABLE bool loadFromFile(const QUrl fileName);
Q_INVOKABLE bool saveToFile(QUrl filename = QUrl());
Q_INVOKABLE QString getFileName();
Q_INVOKABLE int addWayPoint(const QGeoCoordinate &coordinate, QString description);

//Internal methods
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
    QVector<waypointMarker> waypoints;
    QUrl m_fileName;
    float pathLength;
    float totalHeightGain;
    float totalDescent;

    //gdal stuff
    GDALDataset *testDataSet;
    GDALRasterBand *heightBand;
    double adfGeoTransform[6] = {};
    double adfInvGeoTransform[6] = {};
};
#endif // GPXModel_H
