import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtPositioning 5.9
Item {


    FileDialog {
        id:fileDialog
        property var mode: 'open'
        property var chainOpen: false
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
                fileOperations('open');
            }
        }
    }

    MessageDialog {

            id:fileMessageDialog
            icon: StandardIcon.Question
            standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
            modality: Qt.ApplicationModal

            onYes :{

                if(fileDialog.mode ==='open')
                    fileDialog.chainOpen = true;

                fileOperations('save');

                if(fileDialog.mode === 'close')
                    gpxModel.clearMarkers();
            }

            onNo: {
                mainApplicationWindow.gpxHasChanged = false;
                fileDialog.selectExisting = false;

                if(fileDialog.mode ==='open')
                    fileOperations('open');
                else
                    gpxModel.clearMarkers();

            }
    }

    function fileOperations(mode, title) {

        fileDialog.title = title || (mode + "GPX file");

        if(mode !== undefined)
            fileDialog.mode = mode;


        if(mode === 'open'){
            //Can only select a file that exists
            fileDialog.selectExisting = true;

            //edit in progress so make sure they really do want to discard
            if(mainApplicationWindow.gpxHasChanged){
                fileMessageDialog.title = 'Open a new file';
                fileMessageDialog.text = "Would you like to save the current GPX track? "
                fileMessageDialog.open();
                return;
            }
            fileDialog.open();
        }

        var file = gpxModel.getFileName();

        if(mode === 'saveas' ||(mode ==='save' && file ==='')) {
            fileDialog.open();
            return;
        }

        if(mode === 'save' && file !== ''){
            gpxModel.saveToFile();
            mainApplicationWindow.gpxHasChanged = false;
            return;
        }

        if(mode === 'close' && mainApplicationWindow.gpxHasChanged) {
            fileMessageDialog.title = 'Close file';
            fileMessageDialog.text = "Would you like to save the current GPX track?"
            fileMessageDialog.open();
            return;
        }
    }
}
