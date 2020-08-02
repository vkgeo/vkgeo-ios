TEMPLATE = app
TARGET = vkgeo

QT += quick quickcontrols2 location positioning purchasing
CONFIG += c++17

DEFINES += QT_DEPRECATED_WARNINGS QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII

INCLUDEPATH += \
    3rdparty/libsodium/include

SOURCES += \
    src/appsettings.cpp \
    src/contextguard.cpp \
    src/cryptohelper.cpp \
    src/main.cpp

OBJECTIVE_SOURCES += \
    src/admobhelper.mm \
    src/batteryhelper.mm \
    src/locationmanagerdelegate.mm \
    src/notificationhelper.mm \
    src/qiosapplicationdelegate+vkgeo.mm \
    src/qiosviewcontroller+vkgeo.mm \
    src/storehelper.mm \
    src/uihelper.mm \
    src/vkgeoapplicationdelegate.mm \
    src/vkhelper.mm

HEADERS += \
    3rdparty/libsodium/include/sodium.h \
    3rdparty/libsodium/include/sodium/core.h \
    3rdparty/libsodium/include/sodium/crypto_aead_aes256gcm.h \
    3rdparty/libsodium/include/sodium/crypto_aead_chacha20poly1305.h \
    3rdparty/libsodium/include/sodium/crypto_aead_xchacha20poly1305.h \
    3rdparty/libsodium/include/sodium/crypto_auth.h \
    3rdparty/libsodium/include/sodium/crypto_auth_hmacsha256.h \
    3rdparty/libsodium/include/sodium/crypto_auth_hmacsha512.h \
    3rdparty/libsodium/include/sodium/crypto_auth_hmacsha512256.h \
    3rdparty/libsodium/include/sodium/crypto_box.h \
    3rdparty/libsodium/include/sodium/crypto_box_curve25519xchacha20poly1305.h \
    3rdparty/libsodium/include/sodium/crypto_box_curve25519xsalsa20poly1305.h \
    3rdparty/libsodium/include/sodium/crypto_core_ed25519.h \
    3rdparty/libsodium/include/sodium/crypto_core_hchacha20.h \
    3rdparty/libsodium/include/sodium/crypto_core_hsalsa20.h \
    3rdparty/libsodium/include/sodium/crypto_core_ristretto255.h \
    3rdparty/libsodium/include/sodium/crypto_core_salsa20.h \
    3rdparty/libsodium/include/sodium/crypto_core_salsa2012.h \
    3rdparty/libsodium/include/sodium/crypto_core_salsa208.h \
    3rdparty/libsodium/include/sodium/crypto_generichash.h \
    3rdparty/libsodium/include/sodium/crypto_generichash_blake2b.h \
    3rdparty/libsodium/include/sodium/crypto_hash.h \
    3rdparty/libsodium/include/sodium/crypto_hash_sha256.h \
    3rdparty/libsodium/include/sodium/crypto_hash_sha512.h \
    3rdparty/libsodium/include/sodium/crypto_kdf.h \
    3rdparty/libsodium/include/sodium/crypto_kdf_blake2b.h \
    3rdparty/libsodium/include/sodium/crypto_kx.h \
    3rdparty/libsodium/include/sodium/crypto_onetimeauth.h \
    3rdparty/libsodium/include/sodium/crypto_onetimeauth_poly1305.h \
    3rdparty/libsodium/include/sodium/crypto_pwhash.h \
    3rdparty/libsodium/include/sodium/crypto_pwhash_argon2i.h \
    3rdparty/libsodium/include/sodium/crypto_pwhash_argon2id.h \
    3rdparty/libsodium/include/sodium/crypto_pwhash_scryptsalsa208sha256.h \
    3rdparty/libsodium/include/sodium/crypto_scalarmult.h \
    3rdparty/libsodium/include/sodium/crypto_scalarmult_curve25519.h \
    3rdparty/libsodium/include/sodium/crypto_scalarmult_ed25519.h \
    3rdparty/libsodium/include/sodium/crypto_scalarmult_ristretto255.h \
    3rdparty/libsodium/include/sodium/crypto_secretbox.h \
    3rdparty/libsodium/include/sodium/crypto_secretbox_xchacha20poly1305.h \
    3rdparty/libsodium/include/sodium/crypto_secretbox_xsalsa20poly1305.h \
    3rdparty/libsodium/include/sodium/crypto_secretstream_xchacha20poly1305.h \
    3rdparty/libsodium/include/sodium/crypto_shorthash.h \
    3rdparty/libsodium/include/sodium/crypto_shorthash_siphash24.h \
    3rdparty/libsodium/include/sodium/crypto_sign.h \
    3rdparty/libsodium/include/sodium/crypto_sign_ed25519.h \
    3rdparty/libsodium/include/sodium/crypto_sign_edwards25519sha512batch.h \
    3rdparty/libsodium/include/sodium/crypto_stream.h \
    3rdparty/libsodium/include/sodium/crypto_stream_chacha20.h \
    3rdparty/libsodium/include/sodium/crypto_stream_salsa20.h \
    3rdparty/libsodium/include/sodium/crypto_stream_salsa2012.h \
    3rdparty/libsodium/include/sodium/crypto_stream_salsa208.h \
    3rdparty/libsodium/include/sodium/crypto_stream_xchacha20.h \
    3rdparty/libsodium/include/sodium/crypto_stream_xsalsa20.h \
    3rdparty/libsodium/include/sodium/crypto_verify_16.h \
    3rdparty/libsodium/include/sodium/crypto_verify_32.h \
    3rdparty/libsodium/include/sodium/crypto_verify_64.h \
    3rdparty/libsodium/include/sodium/export.h \
    3rdparty/libsodium/include/sodium/randombytes.h \
    3rdparty/libsodium/include/sodium/randombytes_internal_random.h \
    3rdparty/libsodium/include/sodium/randombytes_sysrandom.h \
    3rdparty/libsodium/include/sodium/runtime.h \
    3rdparty/libsodium/include/sodium/utils.h \
    3rdparty/libsodium/include/sodium/version.h \
    src/admobhelper.h \
    src/appinitialized.h \
    src/appsettings.h \
    src/batteryhelper.h \
    src/contextguard.h \
    src/cryptohelper.h \
    src/locationmanagerdelegate.h \
    src/notificationhelper.h \
    src/qiosapplicationdelegate.h \
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

QMAKE_CFLAGS += $$(QMAKE_CFLAGS_ENV)
QMAKE_CXXFLAGS += $$(QMAKE_CXXFLAGS_ENV)
QMAKE_LFLAGS += $$(QMAKE_LFLAGS_ENV)

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
            -framework UserNotifications \
            -L$$PWD/ios/3rdparty/libsodium \
            -lsodium

    VK_SDK_FRAMEWORK.files = ios/Frameworks/VKSdkFramework.framework
    VK_SDK_FRAMEWORK.path = Frameworks

    QMAKE_BUNDLE_DATA += VK_SDK_FRAMEWORK

    QMAKE_OBJECTIVE_CFLAGS += $$(QMAKE_OBJECTIVE_CFLAGS_ENV)
    QMAKE_LFLAGS += -ObjC

    QMAKE_RPATHDIR = @executable_path/Frameworks

    QMAKE_APPLE_DEVICE_ARCHS = arm64
    QMAKE_INFO_PLIST = ios/Info.plist
}
