QT       += core qml quick positioning

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS


SOURCES += \
    gisfunctions.cpp \
    gpxmodel.cpp \
    main.cpp \
    mainappwindow.cpp

HEADERS += \
    gisfunctions.h \
    gpxmodel.h \
    mainappwindow.h

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    qml.qrc

DISTFILES += \
    NOTES.md \
    README.md

INCLUDEPATH += /usr/local/include
LIBS += -L/usr/local/lib/ -lgdal
PRE_TARGETDEPS += /usr/local/lib/libgdal.a
