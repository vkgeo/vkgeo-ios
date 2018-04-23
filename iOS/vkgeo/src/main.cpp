#include <QtCore/QLocale>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include "admobhelper.h"

int main(int argc, char *argv[])
{
    QTranslator     translator;
    QGuiApplication app(argc, argv);

    if (translator.load(QString(":/tr/vkgeo_%1").arg(QLocale::system().name()))) {
        app.installTranslator(&translator);
    }

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(QStringLiteral("AdMobHelper"), new AdMobHelper(&app));

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
