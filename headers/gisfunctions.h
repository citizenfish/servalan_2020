#ifndef GISFUNCTIONS_H
#define GISFUNCTIONS_H

#define pi 3.14159265358979323846264338327950288419717
#include <math.h>
double latlondist_vincenty(float slat, float slon, float flat, float flon);
double toRad(double deg);
double toDeg(double rad);

#endif // GISFUNCTIONS_H
