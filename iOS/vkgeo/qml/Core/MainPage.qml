import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.8
import VKHelper 1.0

import "Main"

import "../Util.js" as UtilScript

Page {
    id: mainPage

    header: Rectangle {
        height: mainPage.bannerViewHeight
        color:  "transparent"
    }

    footer: Rectangle {
        height: mainPage.safeAreaBottomMargin + tabBar.height
        color:  "lightsteelblue"

        TabBar {
            id:            tabBar
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            contentHeight: Math.max(Math.max(mapTabButton.implicitHeight, peopleTabButton.implicitHeight),
                                    settingsTabButton.implicitHeight)

            background: Rectangle {
                color: "transparent"
            }

            TabButton {
                id:             mapTabButton
                implicitHeight: UtilScript.pt(48)

                background: Rectangle {
                    color: tabBar.currentIndex === 0 ? "steelblue" : "lightsteelblue"
                }

                contentItem: Image {
                    source:   "qrc:/resources/images/main/tab_map.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            TabButton {
                id:             peopleTabButton
                implicitHeight: UtilScript.pt(48)

                background: Rectangle {
                    color: tabBar.currentIndex === 1 ? "steelblue" : "lightsteelblue"
                }

                contentItem: Image {
                    source:   "qrc:/resources/images/main/tab_people.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            TabButton {
                id:             settingsTabButton
                implicitHeight: UtilScript.pt(48)

                background: Rectangle {
                    color: tabBar.currentIndex === 2 ? "steelblue" : "lightsteelblue"
                }

                contentItem: Image {
                    source:   "qrc:/resources/images/main/tab_settings.png"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }

    property bool appInForeground:     Qt.application.active

    property int bannerViewHeight:     AdMobHelper.bannerViewHeight
    property int safeAreaBottomMargin: 0
    property int vkAuthState:          VKHelper.authState

    onAppInForegroundChanged: {
        if (appInForeground) {
            positionSource.active = true;
            updateTimer.running   = true;
        } else {
            positionSource.active = false;
            updateTimer.running   = false;
        }
    }

    onVkAuthStateChanged: {
        if (vkAuthState === VKAuthState.StateAuthorized) {
            VKHelper.updateFriends();
        }
    }

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating ||
            StackView.status === StackView.Active) {
            safeAreaBottomMargin = UIHelper.safeAreaBottomMargin();
        }
    }

    function updateTrustedFriendsLocations() {
        VKHelper.updateTrustedFriendsLocations(true);
    }

    SwipeView {
        anchors.fill: parent
        currentIndex: tabBar.currentIndex
        interactive:  false

        MapSwipe {
            id: mapSwipe
        }

        FriendsSwipe {
            id: friendsSwipe

            onLocateFriendOnMap: {
                mapSwipe.locateItemOnMap(id);

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

        onPositionChanged: {
            mapSwipe.updateMyLocation(position.coordinate);

            VKHelper.reportLocation(position.coordinate.latitude,
                                    position.coordinate.longitude);
        }
    }

    Timer {
        id:       updateTimer
        interval: 1000
        repeat:   true

        onTriggered: {
            VKHelper.updateTrustedFriendsLocations(false);
        }
    }

    Component.onCompleted: {
        VKHelper.friendsUpdated.connect(updateTrustedFriendsLocations);
    }
}
