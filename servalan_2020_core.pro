QT       += core qml quick positioning

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++11



DEFINES += QT_DEPRECATED_WARNINGS


SOURCES += \
    main.cpp \
    src/gisfunctions.cpp \
    src/gpxmodel.cpp

HEADERS += \
    headers/gisfunctions.h \
    headers/gpxmodel.h

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    qml.qrc

DISTFILES += \
    NOTES.md \
    README.md \
    javascript/mapFunctions.js \
    javascript/storageFunctions.js

INCLUDEPATH += /opt/local/include
LIBS += -L/opt/local/lib/ -lgdal
PRE_TARGETDEPS += /opt/local/lib/libgdal.a

