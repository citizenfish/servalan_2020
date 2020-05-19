import QtQuick 2.0
import QtLocation 5.12
import QtQuick.Window 2.3
import QtPositioning 5.12
//TODO slider style only works with 1.4 ??
import QtQuick.Controls 2.14
import "qrc:/javascript/storageFunctions.js" as DB
import "qrc:/javascript/mapFunctions.js" as MF
import "qrc:/qml/components"

Item {
    //Alias needed to expose the mapView id up a level
    property alias mapView : mapView
    property alias osmPlugin: osmPlugin
    property alias zoomStackOutdoorPlugin: zoomStackOutdoorPlugin
    property alias zoomStackRoadPlugin: zoomStackRoadPlugin
    property alias zoomStackLightPlugin: zoomStackLightPlugin
    property alias selectedStartMarker: gpxDragMarkerView.selectedStartMarker
    property alias selectedEndMarker: gpxDragMarkerView.selectedEndMarker

    property alias gpxLine :gpxLine
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
            value: 'qrc:/map-styles/zoomstack-outdoor.json'
        }
    }

    Plugin {
        id: zoomStackRoadPlugin
        name: "mapboxgl"

        PluginParameter {
            name: "mapboxgl.mapping.additional_style_urls"
            value: 'qrc:/map-styles/zoomstack-road.json'
        }
    }

    Plugin {
        id: zoomStackLightPlugin
        name: "mapboxgl"

        PluginParameter {
            name: "mapboxgl.mapping.additional_style_urls"
            value: 'qrc:/map-styles/zoomstack-light.json'
        }
    }

    Map {
        id:mapView
        //Alias needed to expose the mapView id up a level
        property alias mapView : mapView

        anchors.fill: parent
        center: QtPositioning.coordinate(50.395755, -3.514762)
        zoomLevel: 14

        //Pick up mouseclicks on the map
        MouseArea {
            anchors.fill: parent
            enabled: mainApplicationWindow.editMode === 'On' ? true : false
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                MF.mapClicked(mouse.x,mouse.y, mouse.button)
            }

        }

        /************ GPX LINE COMPONENT ***********/

        GPXLine {
            id:gpxLine
        }

        /************ Waypoints ********************/

        GPXWaypoint{
            id: gpxWayPoint
        }




        /************* DRAG MARKERS COMPONENT *************/

        MapItemView {
                //Put AFTER line to render on top and get drag events
                model: gpxModel
                id: gpxDragMarkerView
                property int selectedStartMarker : -1;
                property int selectedEndMarker : -1;
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
        //customising https://doc.qt.io/qt-5/qtquickcontrols2-customize.html#customizing-slider

        id: zoomSlider
        from: 1
        to: 20
        value : 14
        stepSize: 1
        orientation: Qt.Vertical

        onValueChanged: {
            mapView.zoomLevel = zoomSlider.value
        }
    }

}

