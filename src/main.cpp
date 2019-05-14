#include <QtCore/QString>
#include <QtCore/QLocale>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include "vkgeoapplicationdelegate.h"
#include "appinitialized.h"
#include "admobhelper.h"
#include "storehelper.h"
#include "batteryhelper.h"
#include "uihelper.h"
#include "notificationhelper.h"
#include "vkhelper.h"

bool AppInitialized = false;

int main(int argc, char *argv[])
{
    QTranslator     translator;
    QGuiApplication app(argc, argv);

    if (translator.load(QString(":/tr/vkgeo_%1").arg(QLocale::system().name()))) {
        QGuiApplication::installTranslator(&translator);
    }

    AppInitialized = true;

    InitializeVKGeoApplicationDelegate();

    qmlRegisterType<VKAuthState>("VKHelper", 1, 0, "VKAuthState");

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(QStringLiteral("AdMobHelper"), &AdMobHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("StoreHelper"), &StoreHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("BatteryHelper"), &BatteryHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("UIHelper"), &UIHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("NotificationHelper"), &NotificationHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("VKHelper"), &VKHelper::GetInstance());

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return QGuiApplication::exec();
}
