import QtQuick 2.0
import QtLocation 5.12
import QtQuick.Window 2.3
import QtPositioning 5.12
import QtQuick.Controls 2.0
import "storageFunctions.js" as DB
import "mapFunctions.js" as MF

Item {
    //Alias needed to expose the mapView id up a level
    property alias mapView : mapView
    property alias osmPlugin: osmPlugin
    property alias zoomStackOutdoorPlugin: zoomStackOutdoorPlugin
    property alias zoomStackRoadPlugin: zoomStackRoadPlugin
    property alias zoomStackLightPlugin: zoomStackLightPlugin

    anchors.fill: parent
    visible: true

    Plugin {
        id: osmPlugin
        name: "osm"
    }

    //TODO there must be a better way of selecting Zoomstack styles than this
    Plugin {
        id: zoomStackOutdoorPlugin
        name: "mapboxgl"

        PluginParameter {
            name: "mapboxgl.mapping.additional_style_urls"
            value: 'http://0.0.0.0:8080/zoomstack-outdoor.json'
        }
    }

    Plugin {
        id: zoomStackRoadPlugin
        name: "mapboxgl"

        PluginParameter {
            name: "mapboxgl.mapping.additional_style_urls"
            value: 'http://0.0.0.0:8080/zoomstack-road.json'
        }
    }

    Plugin {
        id: zoomStackLightPlugin
        name: "mapboxgl"

        PluginParameter {
            name: "mapboxgl.mapping.additional_style_urls"
            value: 'http://0.0.0.0:8080/zoomstack-light.json'
        }
    }

    Map {
        id:mapView
        //Alias needed to expose the mapView id up a level
        property alias mapView : mapView

        anchors.fill: parent
        center: QtPositioning.coordinate(51.3141, -0.5935)
        zoomLevel: 14

        //Pick up mouseclicks on the map
        MouseArea {
            anchors.fill: parent
            enabled: mainApplicationWindow.editMode === 'On' ? true : false
            onClicked: {
                MF.mapClicked(mouse.x,mouse.y)
            }
        }

        /************ GPX LINE COMPONENT ***********/

        GPXLine {
            id:gpxLine
        }

        /************* DRAG MARKERS COMPONENT *************/

        MapItemView {
                //Put AFTER line to render on top and get drag events
                model: gpxModel
                delegate: GPXDragMarker {

                }
        }

        /**************** EVENT MANAGEMENT *******************/
        //Update footer status as map is zoomed

        onZoomLevelChanged: {
            MF.update_zoom_status();
        }

        onCenterChanged: {
            MF.update_location_status();
        }


        Component.onCompleted: {
            MF.update_zoom_status();
            MF.update_location_status();

        }
    }

    //Zoom control implemented as a slider
    Slider {
        id: zoomSlider
        from: 1
        value: 14
        to: 17
        onValueChanged: {
            mapView.zoomLevel = zoomSlider.value
        }
    }

}

