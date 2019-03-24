TEMPLATE = app
TARGET = vkgeo

QT += quick quickcontrols2 sql location positioning purchasing
CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += src/main.cpp

OBJECTIVE_SOURCES += \
    src/vkgeoapplicationdelegate.mm \
    src/locationmanagerdelegate.mm \
    src/admobhelper.mm \
    src/storehelper.mm \
    src/batteryhelper.mm \
    src/uihelper.mm \
    src/notificationhelper.mm \
    src/vkhelper.mm

HEADERS += \
    src/vkgeoapplicationdelegate.h \
    src/locationmanagerdelegate.h \
    src/admobhelper.h \
    src/storehelper.h \
    src/batteryhelper.h \
    src/batteryhelpershared.h \
    src/uihelper.h \
    src/notificationhelper.h \
    src/vkhelper.h \
    src/vkhelpershared.h

RESOURCES += \
    qml.qrc \
    resources.qrc \
    translations.qrc

TRANSLATIONS += \
    translations/vkgeo_ru.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

ios {
    CONFIG += qtquickcompiler no_default_rpath

    INCLUDEPATH += $$PWD/ios/frameworks
    DEPENDPATH += $$PWD/ios/frameworks

    LIBS += -F $$PWD/ios/frameworks \
            -framework GoogleMobileAds \
            -framework VKSdkFramework \
            -framework AdSupport \
            -framework AvFoundation \
            -framework CFNetwork \
            -framework CoreMedia \
            -framework CoreMotion \
            -framework CoreTelephony \
            -framework CoreVideo \
            -framework GameKit \
            -framework GLKit \
            -framework MediaPlayer \
            -framework MessageUI \
            -framework SafariServices \
            -framework StoreKit \
            -framework SystemConfiguration \
            -framework UserNotifications

    VK_SDK_FRAMEWORK.files = ios/Frameworks/VKSdkFramework.framework
    VK_SDK_FRAMEWORK.path = Frameworks

    QMAKE_BUNDLE_DATA += VK_SDK_FRAMEWORK

    QMAKE_RPATHDIR = @executable_path/Frameworks

    QMAKE_APPLE_DEVICE_ARCHS = arm64
    QMAKE_INFO_PLIST = ios/Info.plist
}
