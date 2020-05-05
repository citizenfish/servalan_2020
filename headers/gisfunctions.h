#ifndef GISFUNCTIONS_H
#define GISFUNCTIONS_H

//#define pi 3.14159265358979323846264338327950288419717

//INCLUDES

#include <QGeoCoordinate>
#include <QDateTime>
#include <QDebug>
#include <math.h>
#include "gdal_priv.h"

//STRUCTURES

struct trackpoint {
    QGeoCoordinate latlon;
    float ele;
    QDateTime time;
};

struct waypoint {
    QGeoCoordinate latlon;
    QString name;
    QString cmt;
    QString desc;
    QString sym;
    float ele;
};

//FUNCTIONS

double latlondist_vincenty(QGeoCoordinate coord1, QGeoCoordinate coord2);
double toRad(double deg);
double toDeg(double rad);

QVector<trackpoint> addHeight( QVector<trackpoint> trackpoints, const int start, const int end);
int indexCoordinate(QVector<trackpoint> &trackpoints, const QGeoCoordinate coordinate, bool insert = true);

#endif // GISFUNCTIONS_H
