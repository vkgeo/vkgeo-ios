TEMPLATE = app
TARGET = vkgeo

QT += quick quickcontrols2 sql location positioning purchasing
CONFIG += c++17

DEFINES += QT_DEPRECATED_WARNINGS QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII

SOURCES += \
    src/contextguard.cpp \
    src/main.cpp

OBJECTIVE_SOURCES += \
    src/admobhelper.mm \
    src/batteryhelper.mm \
    src/locationmanagerdelegate.mm \
    src/notificationhelper.mm \
    src/storehelper.mm \
    src/uihelper.mm \
    src/vkgeoapplicationdelegate.mm \
    src/vkgeoviewcontroller.mm \
    src/vkhelper.mm

HEADERS += \
    src/admobhelper.h \
    src/appinitialized.h \
    src/batteryhelper.h \
    src/contextguard.h \
    src/locationmanagerdelegate.h \
    src/notificationhelper.h \
    src/storehelper.h \
    src/uihelper.h \
    src/vkgeoapplicationdelegate.h \
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
    CONFIG += qtquickcompiler no_default_rpath

    INCLUDEPATH += ios/frameworks
    DEPENDPATH += ios/frameworks

    LIBS += -F $$PWD/ios/frameworks \
            -framework GoogleAppMeasurement \
            -framework GoogleMobileAds \
            -framework GoogleUtilities \
            -framework PromisesObjC \
            -framework nanopb \
            -framework VKSdkFramework \
            -framework UIKit \
            -framework StoreKit \
            -framework CoreLocation \
            -framework UserNotifications

    VK_SDK_FRAMEWORK.files = ios/Frameworks/VKSdkFramework.framework
    VK_SDK_FRAMEWORK.path = Frameworks

    QMAKE_BUNDLE_DATA += VK_SDK_FRAMEWORK

    QMAKE_LFLAGS += -ObjC
    QMAKE_RPATHDIR = @executable_path/Frameworks

    QMAKE_APPLE_DEVICE_ARCHS = arm64
    QMAKE_INFO_PLIST = ios/Info.plist
}
