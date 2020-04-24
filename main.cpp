#include "mainappwindow.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include "gpxmodel.h"

using namespace std;
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<GPXModel>("GPXModel", 1, 0, "GPXModel");

    engine.load(QUrl(QStringLiteral("qrc:/mainAppWindow.qml")));

    return app.exec();
}
