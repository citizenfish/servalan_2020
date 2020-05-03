import QtQuick 2.0
import QtLocation 5.12
import QtQuick.Window 2.3
import QtPositioning 5.12
//TODO slider style only works with 1.4 ??
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
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
        center: QtPositioning.coordinate(50.395755, -3.514762)
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
        minimumValue: 1
        value: 14
        maximumValue: 20
        onValueChanged: {
            mapView.zoomLevel = zoomSlider.value
        }
        style: SliderStyle {

                groove: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 4
                    color: "gray"
                    radius: 4
                }
                handle: Rectangle {
                    anchors.centerIn: parent
                    color: control.pressed ? "white" : "lightgray"
                    border.color: "gray"
                    border.width: 2
                    implicitWidth: 17
                    implicitHeight: 17
                    radius: 8
                }
                //TODO get this working
                tickmarks: Repeater {
                    id: repeater
                    model: control.stepSize > 0 ? 1 + (control.maximumValue - control.minimumValue) / control.stepSize : 0
                    width: control.orientation === Qt.Vertical ? control.height : control.width
                    height: control.orientation === Qt.Vertical ? control.width : control.height
                       Rectangle {
                            color: "black"
                            width: 1 ; height: 10
                           y: control.orientation === Qt.Vertical ? control.width : control.height
                           //Position ticklines from styleData.handleWidth to width - styleData.handleWidth/2
                           //position them at an half handle width increment
                          x: styleData.handleWidth / 2 + index * ((repeater.width - styleData.handleWidth) / (repeater.count>1 ? repeater.count-1 : 1))
                          opacity: 1
                      }
                }
            }
    }

}

