import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtPositioning 5.9
import "qrc:/javascript/storageFunctions.js" as DB

Item {

    //Expose javascript here so it gets scope
    property var fileOperations: DB.fileOperations

    FileDialog {
        id:backDropFileLoader

        defaultSuffix: 'gpx'
        nameFilters: ["GPX Files (*.gpx *.GPX)", "All Files (*)"]

        onAccepted: {
            backdropGPXModel.clearMarkers();
            backdropGPXModel.loadFromFile(backDropFileLoader.fileUrl);
            appMapView.mapView.fitViewportToVisibleMapItems();
        }
    }

    FileDialog {
        id:fileDialog
        property var mode: 'open'
        property var chainOpen: false

        defaultSuffix: 'gpx'
        nameFilters: ["GPX Files (*.gpx *.GPX)", "All Files (*)"]

        sidebarVisible: true

        onAccepted: {

            if(fileDialog.mode === 'open') {
                 //clear markers from map
                 gpxModel.clearMarkers();
                 gpxModel.loadFromFile(fileDialog.fileUrl);
                 appMapView.mapView.fitViewportToVisibleMapItems();
            }

            if(fileDialog.mode ===  'saveas' || fileDialog.mode === 'save') {
                gpxModel.saveToFile(fileDialog.fileUrl);
                mainApplicationWindow.gpxHasChanged = false;
            }

            //Used for when we do an open after saving
            if(fileDialog.chainOpen){
                fileDialog.chainOpen = false;
                DB.fileOperations('open');
            }
        }


    }

    FileDialog {
        id: srtmFileChooser
        defaultSuffix:  'tif'
        nameFilters: ["TIF Files(*.tif)", "All Files (*)"]

        onAccepted: {
            mainApplicationWindowSettings.srtm_height = srtmFileChooser.fileUrl
            gpxModel.setSRTMFile(srtmFileChooser.fileUrl)
        }
    }

    MessageDialog {

            //Modal window used for warnings during file operations
            id:fileMessageDialog
            icon: StandardIcon.Question
            standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
            modality: Qt.ApplicationModal

            onYes :{

                if(fileDialog.mode ==='open')
                    fileDialog.chainOpen = true;

                DB.fileOperations('save');

                if(fileDialog.mode === 'close')
                    gpxModel.clearMarkers();
            }

            onNo: {
                mainApplicationWindow.gpxHasChanged = false;
                fileDialog.selectExisting = false;

                if(fileDialog.mode ==='open')
                    DB.fileOperations('open');
                else
                    gpxModel.clearMarkers();

            }
    }

}
