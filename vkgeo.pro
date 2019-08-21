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
    src/appinitialized.h \
    src/vkgeoapplicationdelegate.h \
    src/locationmanagerdelegate.h \
    src/admobhelper.h \
    src/storehelper.h \
    src/batteryhelper.h \
    src/uihelper.h \
    src/notificationhelper.h \
    src/vkhelper.h

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
    CONFIG += qtquickcompiler

    INCLUDEPATH += $$PWD/ios/frameworks
    DEPENDPATH += $$PWD/ios/frameworks

    LIBS += -F $$PWD/ios/frameworks \
            -framework GoogleAppMeasurement \
            -framework GoogleMobileAds \
            -framework GoogleUtilities \
            -framework nanopb \
            -framework VKSdkFramework \
            -framework UserNotifications

    VK_SDK_FRAMEWORK.files = ios/Frameworks/VKSdkFramework.framework
    VK_SDK_FRAMEWORK.path = Frameworks

    QMAKE_BUNDLE_DATA += VK_SDK_FRAMEWORK

    QMAKE_LFLAGS += -ObjC

    QMAKE_APPLE_DEVICE_ARCHS = arm64
    QMAKE_INFO_PLIST = ios/Info.plist
}
