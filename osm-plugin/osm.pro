TARGET = qtgeoservices_osm

DISTDIR = /Users/daveb/dev/Qt/5.14.2/Src/qtlocation/src/plugins/geoservices/osm/.obj/qtgeoservices_osm1.0.0

QT += location-private positioning-private network concurrent

QT_FOR_CONFIG += location-private
qtConfig(location-labs-plugin): DEFINES += LOCATIONLABS

HEADERS += \
    qgeoserviceproviderpluginosm.h \
    qgeotiledmappingmanagerengineosm.h \
    qgeotilefetcherosm.h \
    qgeomapreplyosm.h \
    qgeocodingmanagerengineosm.h \
    qgeocodereplyosm.h \
    qgeoroutingmanagerengineosm.h \
    qgeoroutereplyosm.h \
    qplacemanagerengineosm.h \
    qplacesearchreplyosm.h \
    qplacecategoriesreplyosm.h \
    qgeotiledmaposm.h \
    qgeofiletilecacheosm.h \
    qgeotileproviderosm.h

SOURCES += \
    qgeoserviceproviderpluginosm.cpp \
    qgeotiledmappingmanagerengineosm.cpp \
    qgeotilefetcherosm.cpp \
    qgeomapreplyosm.cpp \
    qgeocodingmanagerengineosm.cpp \
    qgeocodereplyosm.cpp \
    qgeoroutingmanagerengineosm.cpp \
    qgeoroutereplyosm.cpp \
    qplacemanagerengineosm.cpp \
    qplacesearchreplyosm.cpp \
    qplacecategoriesreplyosm.cpp \
    qgeotiledmaposm.cpp \
    qgeofiletilecacheosm.cpp \
    qgeotileproviderosm.cpp


OTHER_FILES += \
    osm_plugin.json

PLUGIN_TYPE = geoservices
PLUGIN_CLASS_NAME = QGeoServiceProviderFactoryOsm
load(qt_plugin)
