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

        if (appInForeground && vkAuthState === VKAuthState.StateAuthorized) {
            VKHelper.updateFriends();
        }
    }

    onVkAuthStateChanged: {
        if (appInForeground && vkAuthState === VKAuthState.StateAuthorized) {
            VKHelper.updateFriends();
        }
    }

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating ||
            StackView.status === StackView.Active) {
            safeAreaBottomMargin = UIHelper.safeAreaBottomMargin();
        }
    }

    function updateTrustedFriendsCoords(friends_list) {
        VKHelper.updateTrustedFriendsCoords();
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
        }

        SettingsSwipe {
            id: settingsSwipe
        }
    }

    PositionSource {
        id:                          positionSource
        updateInterval:              1000
        preferredPositioningMethods: PositionSource.AllPositioningMethods

        property int reportInterval:  15000
        property real lastReportTime: 0.0

        onPositionChanged: {
            mapSwipe.updateMyCoordinate(position.coordinate);

            if ((new Date()).getTime() > lastReportTime + reportInterval &&
                VKHelper.authState === VKAuthState.StateAuthorized) {
                lastReportTime = (new Date()).getTime();

                VKHelper.reportCoordinate(position.coordinate.latitude,
                                          position.coordinate.longitude);
            }
        }
    }

    Timer {
        id:               updateTimer
        interval:         15000
        repeat:           true
        triggeredOnStart: true

        onTriggered: {
            mainPage.updateTrustedFriendsCoords([]);
        }
    }

    Component.onCompleted: {
        VKHelper.friendsUpdated.connect(updateTrustedFriendsCoords);
    }
}
