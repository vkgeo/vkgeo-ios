#include <QtCore/QString>
#include <QtCore/QLocale>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuickControls2/QQuickStyle>

#include "admobhelper.h"
#include "appinitialized.h"
#include "batteryhelper.h"
#include "notificationhelper.h"
#include "storehelper.h"
#include "uihelper.h"
#include "vkgeoapplicationdelegate.h"
#include "vkhelper.h"

bool AppInitialized = false;

int main(int argc, char *argv[])
{
    QTranslator     translator;
    QGuiApplication app(argc, argv);

    if (translator.load(QStringLiteral(":/tr/vkgeo_%1").arg(QLocale::system().name()))) {
        QGuiApplication::installTranslator(&translator);
    }

    AppInitialized = true;

    InitializeVKGeoApplicationDelegate();

    qmlRegisterUncreatableType<UITheme>    ("UIHelper", 1, 0, "UITheme",     QStringLiteral("Could not create an object of type UITheme"));
    qmlRegisterUncreatableType<VKAuthState>("VKHelper", 1, 0, "VKAuthState", QStringLiteral("Could not create an object of type VKAuthState"));

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(QStringLiteral("AdMobHelper"), &AdMobHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("BatteryHelper"), &BatteryHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("NotificationHelper"), &NotificationHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("StoreHelper"), &StoreHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("UIHelper"), &UIHelper::GetInstance());
    engine.rootContext()->setContextProperty(QStringLiteral("VKHelper"), &VKHelper::GetInstance());

    QQuickStyle::setStyle(QStringLiteral("Default"));

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    } else {
        return QGuiApplication::exec();
    }
}
