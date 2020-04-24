import QtQuick 2.0
import QtLocation 5.12
import QtQuick.Window 2.3
import QtPositioning 5.12
import QtQuick.Controls 2.0
import "storageFunctions.js" as DB

Item {
    //Alias needed to expose the mapView id up a level
    property alias mapView : mapView
    property alias osmPlugin: osmPlugin
    property alias mapboxPlugin: mapboxPlugin

    anchors.fill: parent
    visible: true

    Plugin {
        id: osmPlugin
        name: "osm"
    }

    Plugin {
        id: mapboxPlugin
        name: "mapboxgl"

    }

    Map {
        id:mapView
        //Alias needed to expose the mapView id up a level
        property alias mapView : mapView

        anchors.fill: parent
        //plugin: mapPlugin//zoomStack //mapPlugin
        center: QtPositioning.coordinate(51.3141, -0.5935) // Surrey Heath
        zoomLevel: 14




        //for Zoomstack
        MapParameter {
            type: "source"
            property var sourceType: 'vector'
            property var url: 'https://s3-eu-west-1.amazonaws.com/tiles.os.uk/v2/data/vector/open-zoomstack/config.json'
        }

        //Pick up mouseclicks on the map
        MouseArea {
            anchors.fill: parent
            enabled: mainApplicationWindow.editMode === 'On' ? true : false
            onClicked: {
                mapView.mapClicked(mouse.x,mouse.y)
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
            footerBar.update_zoom_status('Zoom ' + Math.round(zoomLevel));
        }

        onCenterChanged: {
            footerBar.update_location_status('Lonlat(' + mapView.center.longitude.toFixed(3) + ',' + mapView.center.latitude.toFixed(3) +')');
        }


        /**************** MAP SPECIFIC FUNCTIONS *************/

        function mapClicked(x,y) {
            var coord = mapView.toCoordinate(Qt.point(x,y))
            DB.modelCommandExecute('addMarker', {"coordinate" : coord});
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

