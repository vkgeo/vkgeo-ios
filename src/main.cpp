#include <QtCore/QLocale>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include "vkgeoapplicationdelegate.h"
#include "admobhelper.h"
#include "storehelper.h"
#include "batteryhelpershared.h"
#include "uihelper.h"
#include "notificationhelper.h"
#include "vkhelpershared.h"

BatteryHelper *BatteryHelperShared = nullptr;
VKHelper      *VKHelperShared      = nullptr;

int main(int argc, char *argv[])
{
    QTranslator     qt_extra_translator,
                    app_translator;
    QGuiApplication app(argc, argv);

    if (qt_extra_translator.load(QString(":/tr/qt_extra_%1").arg(QLocale::system().name()))) {
        QGuiApplication::installTranslator(&qt_extra_translator);
    }
    if (app_translator.load(QString(":/tr/vkgeo_%1").arg(QLocale::system().name()))) {
        QGuiApplication::installTranslator(&app_translator);
    }

    InitializeVKGeoApplicationDelegate();

    BatteryHelperShared = new BatteryHelper(&app);
    VKHelperShared      = new VKHelper(&app);

    qmlRegisterType<VKAuthState>("VKHelper", 1, 0, "VKAuthState");

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(QStringLiteral("AdMobHelper"), new AdMobHelper(&app));
    engine.rootContext()->setContextProperty(QStringLiteral("StoreHelper"), new StoreHelper(&app));
    engine.rootContext()->setContextProperty(QStringLiteral("BatteryHelper"), BatteryHelperShared);
    engine.rootContext()->setContextProperty(QStringLiteral("UIHelper"), new UIHelper(&app));
    engine.rootContext()->setContextProperty(QStringLiteral("NotificationHelper"), new NotificationHelper(&app));
    engine.rootContext()->setContextProperty(QStringLiteral("VKHelper"), VKHelperShared);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return QGuiApplication::exec();
}
