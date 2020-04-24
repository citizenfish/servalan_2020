import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

StatusBar {

    RowLayout {
        anchors.fill: parent

        Label {
            id: zoomStatus
            text: "Zoom 14"
        }

        Label {
            id: locationStatus
            text: "Location"
        }

        Label {
            id: editStatus
            text: "Edit Mode: Off"
        }
    }

    function update_zoom_status(text){
        zoomStatus.text = text;
    }

    function update_location_status(text){
        locationStatus.text = text;
    }

    function update_edit_status(text) {
        editStatus.text = "Edit Mode: " + text;
    }
}
