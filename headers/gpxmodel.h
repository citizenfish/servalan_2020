#ifndef MAPMARKER_H
#define MAPMARKER_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QDate>
#include <QQuickItem>
#include <QXmlStreamReader>
#include "gdal_priv.h"
#include "gisfunctions.h"



class GPXModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QVariantList path READ path NOTIFY pathChanged)

public:

//Constructor
GPXModel(QObject *parent=nullptr);

//Definition of roles used by QML to access the model
enum GPXModelRoles{positionRole = Qt::UserRole, pathRole, itemRole};

//Externally invokable methods
Q_INVOKABLE int addMarker(const QGeoCoordinate coordinate, bool appendFlag = true);
Q_INVOKABLE QGeoCoordinate deleteMarkerAtIndex(int index);
Q_INVOKABLE void clearMarkers( );
Q_INVOKABLE QGeoCoordinate updateMarkerLocation(const QGeoCoordinate &coordinate, int index);
Q_INVOKABLE int setNumDragHandles(int num);
Q_INVOKABLE bool loadFromFile(const QUrl fileName);
Q_INVOKABLE bool saveToFile(QUrl filename = QUrl());
Q_INVOKABLE QString getFileName();
Q_INVOKABLE QString getTrackName();
Q_INVOKABLE QString setTrackName(QString trackname );
Q_INVOKABLE int setEditLocationFromCoordinate(const QGeoCoordinate coordinate);
Q_INVOKABLE void forceRedraw(const int index1, int range = -1);
Q_INVOKABLE int deleteMarkerRange(const int index1, const int index2);
Q_INVOKABLE int insertMarkerRangeUndo(const int index1, const int count, const int undo_pointer);

//Internal methods
int rowCount(const QModelIndex &parent = QModelIndex()) const override;
QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
QHash<int, QByteArray> roleNames() const override;
QVariantList path() const;

void setEditLocation(const int pathIndex,  int range = -1);

signals:
    void pathChanged();
    void fileLoaded();

private:
    int numDragHandles = 30;
    QVector<trackpoint> m_trackpoints;
    QVector<trackpoint> edit_markers;
    QVector<waypoint> m_waypoints;
    QUrl m_fileName;
    QString m_trackName = "";

    QVector<trackpoint> undo_trackpoints;

    float pathLength;
    float totalHeightGain;
    float totalDescent;


};
#endif // GPXModel_H
