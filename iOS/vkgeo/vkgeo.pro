QT += quick quickcontrols2 sql location positioning
CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += src/main.cpp

OBJECTIVE_SOURCES += \
    src/admobhelper.mm

HEADERS += \
    src/admobhelper.h

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
    LIBS += -F $$PWD/ios/frameworks \
            -framework GoogleMobileAds \
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
            -framework StoreKit \
            -framework SystemConfiguration

    QMAKE_APPLE_DEVICE_ARCHS = arm64
    QMAKE_INFO_PLIST = ios/Info.plist
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
