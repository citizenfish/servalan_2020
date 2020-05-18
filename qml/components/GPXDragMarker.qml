import QtQuick 2.0
import QtPositioning 5.8
import QtLocation 5.9
import "qrc:/javascript/storageFunctions.js" as DB
import "qrc:/javascript/mapFunctions.js" as MF

MapCircle{

    center: positionRole
    //This gets me the id of the marker so I can change its position
    property variant itemDetails : itemRole
    property var mDetails //holds drag starting position

    id:gpxDragMarker
    radius: 50
    color: 'yellow'
    opacity: 0.6


    Drag.onDragFinished: MF.marker_dragged();
    MouseArea{
        enabled: mainApplicationWindow.editMode == 'On' ? true : false
        anchors.fill: parent
        drag.target: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property bool dragActive: drag.active;

        onEntered: {
            //storing the original position before drag for undo, have to convert to coordinate as center is a varible object and does not serialize
            mDetails = QtPositioning.coordinate(gpxDragMarker.center.latitude, gpxDragMarker.center.longitude);
        }

        onClicked: {
            console.log("SELECTED " + itemDetails + " " + mouse.button);
            MF.marker_clicked(itemDetails, mouse.button);

        }

        onDoubleClicked: MF.marker_double_clicked();

        onDragActiveChanged: {
            if(!drag.active){
                MF.marker_dragged();
            }
        }
    }


    Component.onCompleted: {
        if(itemDetails === selectedStartMarker) {
            color = 'green';
        }

        if(itemDetails === selectedEndMarker) {
            color = 'red'
        }

        if(itemDetails < selectedEndMarker && itemDetails > selectedStartMarker){
            color = 'blue';
        }
    }

}
