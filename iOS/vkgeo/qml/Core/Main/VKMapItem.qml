import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtPositioning 5.8
import QtLocation 5.9

import "../../Util.js" as UtilScript

MapQuickItem {
    id:          vkMapItem
    anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)

    property bool valid:      false

    property real updateTime: 0.0

    property string id:       ""
    property string photoUrl: ""

    sourceItem: OpacityMask {
        id:      opacityMask
        width:   UtilScript.pt(48)
        height:  UtilScript.pt(48)
        visible: vkMapItem.valid

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

    onCoordinateChanged: {
        valid = true;
    }
}
