import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtPositioning 5.8
import QtLocation 5.9

import "../../Util.js" as UtilScript

Item {
    id: mapSwipe

    function updateMyCoordinate(coordinate) {
        if (map.myMapItem !== null) {
            map.myMapItem.coordinate = coordinate;
            map.myMapItem.updateTime = (new Date()).getTime() / 1000;
        }
    }

    function updateMapItems() {
        var tracked_map_item_id = null;

        if (map.trackedMapItem !== null) {
            tracked_map_item_id = map.trackedMapItem.id;
        }

        map.trackMapItem(null);

        for (var i = map.mapItems.length - 1; i >= 0; i--) {
            var map_item = map.mapItems[i];

            map.removeMapItem(map_item);

            if (map_item !== map.myMapItem) {
                map_item.destroy();
            }
        }

        var friends_list = VKHelper.getFriendsList();

        var component = Qt.createComponent("VKMapItem.qml");

        if (component.status === Component.Ready) {
            for (var j = 0; j < friends_list.length; j++) {
                var frnd = friends_list[j];

                if (frnd.trusted) {
                    var new_map_item = component.createObject(map, { "id": frnd.id, "photoUrl": frnd.photoUrl });

                    map.addMapItem(new_map_item);

                    if (new_map_item.id === tracked_map_item_id) {
                        map.trackMapItem(new_map_item);
                    }
                }
            }
        } else {
            console.log(component.errorString());
        }

        map.addMapItem(map.myMapItem);

        if (tracked_map_item_id === "") {
            map.trackMapItem(map.myMapItem);
        }
    }

    function updateMapItemCoordinate(id, update_time, latitude, longitude) {
        for (var i = 0; i < map.mapItems.length; i++) {
            var map_item = map.mapItems[i];

            if (id === map_item.id) {
                map_item.coordinate = QtPositioning.coordinate(latitude, longitude);
                map_item.updateTime = update_time;

                break;
            }
        }
    }

    function locateItemOnMap(id) {
        for (var i = 0; i < map.mapItems.length; i++) {
            var map_item = map.mapItems[i];

            if (id === map_item.id) {
                map.trackMapItem(map_item);

                break;
            }
        }
    }

    Map {
        id:           map
        anchors.fill: parent

        property bool trackingActive:     false

        property real trackingBearing:    0.0
        property real trackingTilt:       0.0
        property real trackingZoomLevel:  18.0

        property var myMapItem:           null
        property var trackedMapItem:      null

        plugin: Plugin {
            name: "osm"
        }

        onBearingChanged: {
            if (!trackingActive) {
                trackMapItem(null);
            }
        }

        onCenterChanged: {
            if (!trackingActive) {
                trackMapItem(null);
            }
        }

        onTiltChanged: {
            if (!trackingActive) {
                trackMapItem(null);
            }
        }

        onZoomLevelChanged: {
            if (!trackingActive) {
                trackMapItem(null);
            }
        }

        function trackMapItem(map_item) {
            if (trackedMapItem !== null) {
                trackedMapItem.coordinateChanged.disconnect(centerOnTrackedItem);
            }

            trackedMapItem = map_item;

            if (trackedMapItem !== null) {
                trackedMapItem.coordinateChanged.connect(centerOnTrackedItem);
            }

            centerOnTrackedItem();
        }

        function centerOnTrackedItem() {
            if (trackedMapItem !== null) {
                trackingActive = true;

                center    = trackedMapItem.coordinate;
                bearing   = trackingBearing;
                tilt      = trackingTilt;
                zoomLevel = trackingZoomLevel;

                trackingActive = false;
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
        enabled:              map.myMapItem != null && map.myMapItem.valid

        MouseArea {
            anchors.fill: parent

            onClicked: {
                map.trackMapItem(map.myMapItem);
            }
        }
    }

    Component.onCompleted: {
        var component = Qt.createComponent("VKMapItem.qml");

        if (component.status === Component.Ready) {
            map.myMapItem = component.createObject(map);

            map.myMapItem.id       = "";
            map.myMapItem.photoUrl = Qt.binding(function() { return VKHelper.photoUrl; });

            map.addMapItem(map.myMapItem);
            map.trackMapItem(map.myMapItem);
        } else {
            console.log(component.errorString());
        }

        VKHelper.friendsUpdated.connect(updateMapItems);
        VKHelper.trustedFriendCoordUpdated.connect(updateMapItemCoordinate);
    }
}
