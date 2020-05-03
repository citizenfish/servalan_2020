import QtQuick 2.14
import QtQuick.Window 2.3
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2

import "storageFunctions.js" as DB
import GPXModel 1.0


ApplicationWindow {

    id:mainApplicationWindow
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
