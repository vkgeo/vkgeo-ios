import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtPositioning 5.8
import QtLocation 5.9

import "../../Util.js" as UtilScript

MapQuickItem {
    id:          vkMapItem
    width:       sourceItem.width
    height:      sourceItem.height
    anchorPoint: Qt.point(width / 2, height / 2)

    property bool valid:           false
    property bool locationUnknown: false

    property int locationTimeout:  12 * 60 * 60

    property real updateTime:      0.0

    property string userId:        ""
    property string photoUrl:      ""

    sourceItem: Rectangle {
        width:   UtilScript.pt(48)
        height:  UtilScript.pt(48)
        color:   "transparent"
        visible: vkMapItem.valid

        OpacityMask {
            id:           opacityMask
            anchors.fill: parent

            source: Image {
                width:    opacityMask.width
                height:   opacityMask.height
                source:   photoUrl
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

        Image {
            x:        opacityMask.width  / 2 + opacityMask.width  / 2 * Math.sin(angle) - width  / 2
            y:        opacityMask.height / 2 + opacityMask.height / 2 * Math.cos(angle) - height / 2
            z:        1
            width:    UtilScript.pt(16)
            height:   UtilScript.pt(16)
            source:   "qrc:/resources/images/main/avatar_unknown_location_label.png"
            fillMode: Image.PreserveAspectFit
            visible:  vkMapItem.locationUnknown

            property real angle: Math.PI / 4
        }
    }

    onCoordinateChanged: {
        valid = true;
    }

    onUpdateTimeChanged: {
        updateState();
    }

    function updateState() {
        if ((new Date()).getTime() / 1000 > updateTime + locationTimeout) {
            locationUnknown = true;
        } else {
            locationUnknown = false;
        }
    }

    Component.onCompleted: {
        updateState();
    }
}
