import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "qrc:/javascript/mapFunctions.js" as MF
import "qrc:/javascript/storageFunctions.js" as DB

ToolBar {

    RowLayout {
        Button {
            text: qsTr("Controls")
            onClicked: {
                if(sideBar.visible)
                    sideBar.close()
                else
                    sideBar.open()
            }
        }
        Button {
            text: qsTr("Profile")
            onClicked: mapProfileWindow.show()
        }
        Button {
            text: qsTr("Edit")
            onClicked: MF.toggleEditMode();

        }

        Button {
            text: qsTr("+")
            onClicked: MF.zoom('in');

        }

        Button {
            text: qsTr("-")
            onClicked: MF.zoom('out');

        }

        Button{
            text: qsTr("DELETE MARKERS")
            onClicked: {
                var del = DB.modelCommandExecute('deleteMarkerRange', {"start" : appMapView.selectedStartMarker, "end" : appMapView.selectedEndMarker});
                console.log("Command output "+ del);
            }
        }

        Button{
            text: qsTr("SRTM")
            onClicked: {
                fileManager.fileOperations('srtm', 'Choose SRTM Height File');
            }
        }
    }


}
