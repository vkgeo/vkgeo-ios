import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtPositioning 5.8
import QtLocation 5.9

import "../Util.js" as UtilScript

Page {
    id: mainPage

    header: TabBar {
        id:            tabBar
        topPadding:    mainPage.bannerViewHeight
        contentHeight: Math.max(mapTabButton.implicitHeight, peopleTabButton.implicitHeight)

        TabButton {
            id:             mapTabButton
            implicitHeight: UtilScript.pt(48)

            contentItem: Image {
                source:   "qrc:/resources/images/main/tab_map.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        TabButton {
            id:             peopleTabButton
            implicitHeight: UtilScript.pt(48)

            contentItem: Image {
                source:   "qrc:/resources/images/main/tab_people.png"
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    property bool appInForeground:  Qt.application.active
    property int  bannerViewHeight: AdMobHelper.bannerViewHeight

    onAppInForegroundChanged: {
        if (appInForeground && StackView.status === StackView.Active) {
            positionSource.active = true;
        } else {
            positionSource.active = false;
        }
    }

    StackView.onStatusChanged: {
        if (appInForeground && StackView.status === StackView.Active) {
            positionSource.active = true;
        } else {
            positionSource.active = false;
        }
    }

    SwipeView {
        anchors.fill: parent
        currentIndex: tabBar.currentIndex
        interactive:  false

        Item {
            Map {
                id:           map
                anchors.fill: parent

                property bool trackingMyLocation: true
                property real trackingBearing:    0.0
                property real trackingTilt:       0.0
                property real trackingZoomLevel:  18.0

                plugin: Plugin {
                    name: "osm"
                }

                onBearingChanged: {
                    trackingMyLocation = false;
                }

                onCenterChanged: {
                    trackingMyLocation = false;
                }

                onTiltChanged: {
                    trackingMyLocation = false;
                }

                onZoomLevelChanged: {
                    trackingMyLocation = false;
                }

                function centerOnMyItem() {
                    center    = myMapItem.coordinate;
                    bearing   = trackingBearing;
                    tilt      = trackingTilt;
                    zoomLevel = trackingZoomLevel;
                }

                MapQuickItem {
                    id:          myMapItem
                    anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)

                    sourceItem: OpacityMask {
                        id:      opacityMask
                        width:   UtilScript.pt(48)
                        height:  UtilScript.pt(48)
                        visible: positionSource.valid

                        source: Image {
                            width:    opacityMask.width
                            height:   opacityMask.height
                            source:   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7EjayPhJBi0OEjMthBxFA5Z9X6Ckji13CqQPiPDJ3Gc1YTNKY"
                            fillMode: Image.Stretch
                            visible:  false
                        }

                        maskSource: Image {
                            width:    opacityMask.width
                            height:   opacityMask.height
                            source:   "qrc:/resources/images/main/avatar_mask.png"
                            fillMode: Image.PreserveAspectFit
                            visible:  false
                        }
                    }

                    onCoordinateChanged: {
                        if (map.trackingMyLocation) {
                            map.centerOnMyItem();

                            map.trackingMyLocation = true;
                        }
                    }
                }
            }

            Button {
                id:                   trackLocationButton
                anchors.right:        parent.right
                anchors.bottom:       parent.bottom
                anchors.rightMargin:  UtilScript.pt(4)
                anchors.bottomMargin: UtilScript.pt(16)
                z:                    1
                implicitWidth:        UtilScript.pt(64)
                implicitHeight:       UtilScript.pt(64)
                enabled:              positionSource.valid

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Image {
                    source:   trackLocationButton.enabled ? "qrc:/resources/images/main/track_location.png" :
                                                            "qrc:/resources/images/main/track_location_disabled.png"
                    fillMode: Image.PreserveAspectFit
                }

                onClicked: {
                    map.centerOnMyItem();

                    map.trackingMyLocation = true;
                }
            }
        }

        Item {

        }
    }

    PositionSource {
        id:                          positionSource
        updateInterval:              1000
        preferredPositioningMethods: PositionSource.AllPositioningMethods

        onPositionChanged: {
            if (valid) {
                myMapItem.coordinate = positionSource.position.coordinate;
            }
        }
    }
}
