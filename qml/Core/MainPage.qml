import QtQuick 2.12
import QtQuick.Controls 2.5
import QtPositioning 5.12
import VKHelper 1.0

import "Main"

import "../Util.js" as UtilScript

Page {
    id: mainPage

    header: Rectangle {
        height: mainPage.bannerViewHeight
        color:  UIHelper.darkTheme ? "midnightblue" : "lightsteelblue"
    }

    background: Rectangle {
        color: UIHelper.darkTheme ? "black" : "white"
    }

    footer: TabBar {
        id: tabBar

        background: Rectangle {
            color: UIHelper.darkTheme ? "midnightblue" : "lightsteelblue"
        }

        TabButton {
            id:             mapTabButton
            implicitHeight: UtilScript.dp(UIHelper.screenDpi, 48)

            background: Rectangle {
                color: tabBar.currentIndex === 0 ? "steelblue" : (UIHelper.darkTheme ? "midnightblue" :
                                                                                       "lightsteelblue")
            }

            contentItem: Image {
                source:   "qrc:/resources/images/main/tab_map.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        TabButton {
            id:             peopleTabButton
            implicitHeight: UtilScript.dp(UIHelper.screenDpi, 48)

            background: Rectangle {
                color: tabBar.currentIndex === 1 ? "steelblue" : (UIHelper.darkTheme ? "midnightblue" :
                                                                                       "lightsteelblue")
            }

            contentItem: Image {
                source:   "qrc:/resources/images/main/tab_people.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        TabButton {
            id:             settingsTabButton
            implicitHeight: UtilScript.dp(UIHelper.screenDpi, 48)

            background: Rectangle {
                color: tabBar.currentIndex === 2 ? "steelblue" : (UIHelper.darkTheme ? "midnightblue" :
                                                                                       "lightsteelblue")
            }

            contentItem: Image {
                source:   "qrc:/resources/images/main/tab_settings.png"
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    readonly property bool appInForeground: Qt.application.state === Qt.ApplicationActive

    readonly property int bannerViewHeight: AdMobHelper.bannerViewHeight
    readonly property int vkAuthState:      VKHelper.authState

    property bool componentCompleted:       false

    onVkAuthStateChanged: {
        if (componentCompleted) {
            if (vkAuthState === VKAuthState.StateNotAuthorized) {
                NotificationHelper.showNotification("NOT_LOGGED_IN_NOTIFICATION", qsTr("You are not logged into your VK account"),
                                                                                  qsTr("Tap to open the application"));
            } else if (vkAuthState === VKAuthState.StateAuthorized) {
                NotificationHelper.hideNotification("NOT_LOGGED_IN_NOTIFICATION");

                VKHelper.updateFriends();
            }
        }
    }

    onComponentCompletedChanged: {
        if (componentCompleted) {
            if (vkAuthState === VKAuthState.StateNotAuthorized) {
                NotificationHelper.showNotification("NOT_LOGGED_IN_NOTIFICATION", qsTr("You are not logged into your VK account"),
                                                                                  qsTr("Tap to open the application"));
            } else if (vkAuthState === VKAuthState.StateAuthorized) {
                NotificationHelper.hideNotification("NOT_LOGGED_IN_NOTIFICATION");

                VKHelper.updateFriends();
            }
        }
    }

    SwipeView {
        anchors.fill: parent
        currentIndex: tabBar.currentIndex
        interactive:  false

        MapSwipe {
            id: mapSwipe

            onProfilePageRequested: {
                friendsSwipe.openProfilePage(userId);
            }
        }

        FriendsSwipe {
            id: friendsSwipe

            onLocationOnMapRequested: {
                mapSwipe.locateItemOnMap(userId);

                tabBar.setCurrentIndex(0);
            }
        }

        SettingsSwipe {
            id: settingsSwipe
        }
    }

    PositionSource {
        id:                          positionSource
        updateInterval:              1000
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        active:                      mainPage.appInForeground

        onPositionChanged: {
            if (position.latitudeValid && position.longitudeValid) {
                VKHelper.updateLocation(position.coordinate.latitude,
                                        position.coordinate.longitude);

                VKHelper.updateBatteryStatus(BatteryHelper.getBatteryStatus(),
                                             BatteryHelper.getBatteryLevel());
            }
        }
    }

    Timer {
        id:       updateTimer
        running:  mainPage.appInForeground
        interval: 1000
        repeat:   true

        onTriggered: {
            VKHelper.updateTrackedFriendsData(false);

            mapSwipe.updateMapItemsStates();
        }
    }

    Connections {
        target: VKHelper

        onEncryptionEnabledChanged: {
            VKHelper.sendDataImmediately();
        }

        onDataSent: {
            VKHelper.updateTrackedFriendsData(true);
        }

        onFriendsUpdated: {
            VKHelper.updateTrackedFriendsData(true);
        }
    }

    Component.onCompleted: {
        componentCompleted = true;
    }
}
