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

    function toggleEditMode(){
        if(mainApplicationWindow.editMode === 'Off'){
             gpxModel.setEditLocation(gpxModel.rowCount());
             this.editMode = 'On';
        }
        else{
            this.editMode = 'Off';
        }
        footerBar.update_edit_status(this.editMode);
    }

    Component.onCompleted: {
        mapChooserWindow.visible = true;

      }

    Shortcut {
        sequence: StandardKey.Undo
        onActivated: DB.modelCommandUndo();
    }

    Shortcut {
        sequence: StandardKey.Redo
        onActivated: DB.modelCommandRedo();
    }
}
