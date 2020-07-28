import QtQuick 2.14
import QtQuick.Window 2.3
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

import GPXModel 1.0

import "qrc:/javascript/storageFunctions.js" as DB
import "qrc:/qml/components"
import "qrc:/qml/map"


ApplicationWindow {

    id:mainApplicationWindow

    Settings {
        //Note that this appears to be instantiated after onCompleted Component.onCompleted so the api key is not known
        id: mainApplicationWindowSettings
        property alias x: mainApplicationWindow.x
        property alias y: mainApplicationWindow.y
        property alias width: mainApplicationWindow.width
        property alias height: mainApplicationWindow.height
        property  var srtm_height: ''
        property var osm_thunderforest_api_key: 'FOO'
    }

    width: 1512
    height: 1000
    visible: true
    property var editMode:'Off'
    //used by open/close operations to prompt for save if edits have been done
    property var gpxHasChanged: false
    //used for undo/redo
    property var commandStack:[];
    property var commandStackPointer: -1;


    menuBar: MainAppWindowMenuBar {
        id: menuBar
    }

    //model for all GPX data currently loaded and displayed on map
    GPXModel{
        id: gpxModel
    }

    //model for a backdrop GPX to trace over
    GPXModel {
        id: backdropGPXModel
    }

    //model for waypoints
    GPXWayPointModel{
        id: wpModel
    }


    MainAppWindowSideBar {
        id: sideBar
    }

    header: MainAppWindowToolBar {
        id: toolBar
    }


    MapView{
      //we get to the map with id: appMapView.mapView
      id: appMapView
      visible: false
    }


    //For opening of GPX files
    FileManager {
        id: fileManager
    }

    MapViewProfileWindow {
        id: mapProfileWindow
    }

    MapChooserWindow{
        id: mapChooserWindow
    }

    footer: MainAppWindowFooterBar{
        id: footerBar
    }


    Component.onCompleted: {
        //Window to choose the map type

        mapChooserWindow.visible = true;
        if(mainApplicationWindowSettings.srtm_height != '') {
            gpxModel.setSRTMFile(mainApplicationWindowSettings.srtm_height);
        }
      }

    Shortcut {
        //UNDO binding
        sequence: StandardKey.Undo
        onActivated: DB.modelCommandUndo();
    }

    Shortcut {
        //REDO binding
        sequence: StandardKey.Redo
        onActivated: DB.modelCommandRedo();
    }
}
