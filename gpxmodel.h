#ifndef MAPMARKER_H
#define MAPMARKER_H


#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QDebug>
#include <QDate>
#include <QQuickItem>
#include <QXmlStreamReader>


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
    }

Q_INVOKABLE int addMarker(const QGeoCoordinate &coordinate, float elevation = -1, QDateTime dateTime = QDateTime::currentDateTime());
Q_INVOKABLE bool loadFromFile(const QUrl fileName);
Q_INVOKABLE bool saveToFile(QUrl filename = QUrl());
Q_INVOKABLE void setEditLocation(const int pathIndex, const int range = 10);
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
    QVector<gpxCoordinate> m_coordinates;
    QVector<gpxCoordinate> edit_markers;
    QUrl m_fileName;
};
#endif // GPXModel_H
