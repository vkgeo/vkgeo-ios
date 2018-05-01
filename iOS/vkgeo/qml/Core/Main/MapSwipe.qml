import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtPositioning 5.8
import QtLocation 5.9

import "../../Util.js" as UtilScript

Item {
    id: mapSwipe

    function updateMyLocation(coordinate) {
        if (map.myMapItem !== null) {
            map.myMapItem.coordinate = coordinate;
            map.myMapItem.updateTime = (new Date()).getTime() / 1000;

            if (!map.wasTouched && map.trackedMapItem === null) {
                map.centerOnMyMapItemOnce();
            }
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

    function updateMapItemLocation(id, update_time, latitude, longitude) {
        for (var i = 0; i < map.mapItems.length; i++) {
            var map_item = map.mapItems[i];

            if (id === map_item.id) {
                map_item.coordinate = QtPositioning.coordinate(latitude, longitude);
                map_item.updateTime = update_time;

                break;
            }
        }

        if (!map.wasTouched && map.trackedMapItem === null) {
            map.showAllMapItems();
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

        property bool wasTouched:           false
        property bool wasCenterOnMyMapItem: false
        property bool autoAction:           false

        property real centerBearing:        0.0
        property real centerTilt:           0.0
        property real centerZoomLevel:      18.0

        property var myMapItem:             null
        property var trackedMapItem:        null

        plugin: Plugin {
            name: "osm"
        }

        onBearingChanged: {
            if (!autoAction) {
                wasTouched = true;

                trackMapItem(null);
            }
        }

        onCenterChanged: {
            if (!autoAction) {
                wasTouched = true;

                trackMapItem(null);
            }
        }

        onTiltChanged: {
            if (!autoAction) {
                wasTouched = true;

                trackMapItem(null);
            }
        }

        onZoomLevelChanged: {
            if (!autoAction) {
                wasTouched = true;

                trackMapItem(null);
            }
        }

        function trackMapItem(map_item) {
            if (trackedMapItem !== null) {
                trackedMapItem.coordinateChanged.disconnect(centerOnTrackedMapItem);
            }

            trackedMapItem = map_item;

            if (trackedMapItem !== null) {
                trackedMapItem.coordinateChanged.connect(centerOnTrackedMapItem);
            }

            centerOnTrackedMapItem();
        }

        function centerOnTrackedMapItem() {
            if (trackedMapItem !== null) {
                autoAction = true;

                center    = trackedMapItem.coordinate;
                bearing   = centerBearing;
                tilt      = centerTilt;
                zoomLevel = centerZoomLevel;

                autoAction = false;
            }
        }

        function centerOnMyMapItemOnce() {
            if (!wasCenterOnMyMapItem && myMapItem !== null) {
                autoAction = true;

                center    = myMapItem.coordinate;
                bearing   = centerBearing;
                tilt      = centerTilt;
                zoomLevel = centerZoomLevel;

                wasCenterOnMyMapItem = true;

                autoAction = false;
            }
        }

        function showAllMapItems() {
            autoAction = true;

            fitViewportToMapItems();

            autoAction = false;
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
        enabled:              map.myMapItem !== null && map.myMapItem.valid

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
        } else {
            console.log(component.errorString());
        }

        VKHelper.friendsUpdated.connect(updateMapItems);
        VKHelper.trustedFriendLocationUpdated.connect(updateMapItemLocation);
    }
}
