import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtPositioning 5.8
import QtLocation 5.9

import "../../Util.js" as UtilScript

Item {
    id: mapSwipe

    function updateMyCoordinate(coordinate) {
        myMapItem.coordinate = coordinate;
    }

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

            property bool valid: false

            sourceItem: OpacityMask {
                id:      opacityMask
                width:   UtilScript.pt(48)
                height:  UtilScript.pt(48)
                visible: myMapItem.valid

                source: Image {
                    width:    opacityMask.width
                    height:   opacityMask.height
                    source:   VKHelper.photoUrl
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
                valid = true;

                if (map.trackingMyLocation) {
                    map.centerOnMyItem();

                    map.trackingMyLocation = true;
                }
            }
        }
    }

    Image {
        anchors.right:        parent.right
        anchors.bottom:       parent.bottom
        anchors.rightMargin:  UtilScript.pt(8)
        anchors.bottomMargin: UtilScript.pt(24)
        z:                    1
        width:                UtilScript.pt(48)
        height:               UtilScript.pt(48)
        source:               enabled ? "qrc:/resources/images/main/button_track.png" :
                                        "qrc:/resources/images/main/button_track_disabled.png"
        fillMode:             Image.PreserveAspectFit
        enabled:              myMapItem.valid

        MouseArea {
            anchors.fill: parent

            onClicked: {
                map.centerOnMyItem();

                map.trackingMyLocation = true;
            }
        }
    }
}
