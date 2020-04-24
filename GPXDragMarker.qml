import QtQuick 2.0
import QtPositioning 5.8
import QtLocation 5.9
import "storageFunctions.js" as DB


MapCircle{

    center: positionRole
    //This gets me the id of the marker so I can change its position
    property variant itemDetails : itemRole
    property var mDetails //holds drag starting position

    id:gpxDragMarker
    radius: 30
    color: '#800000FF'

    Drag.onDragFinished: marker_dragged(circle0);
    MouseArea{
        enabled: mainApplicationWindow.editMode == 'On' ? true : false
        anchors.fill: parent
        drag.target: parent

        onEntered: {
            //storing the original position before drag for undo, have to convert to coordinate as center is a varible object and does not serialize
            mDetails = QtPositioning.coordinate(gpxDragMarker.center.latitude, gpxDragMarker.center.longitude);
        }

        property bool dragActive: drag.active;

        onDoubleClicked: marker_double_clicked();
        onDragActiveChanged: {
            if(!drag.active){
                marker_dragged();
            }
        }
    }

    function marker_dragged() {
        var coord = mapView.toCoordinate(Qt.point(x,y));
        DB.modelCommandExecute('updateMarkerLocation', {"coordinate" : coord, "itemDetails" : itemDetails, "oCoordinate" : mDetails});

    }

    function marker_double_clicked() {
        DB.modelCommandExecute('deleteMarkerAtIndex', {"index" : itemDetails});
    }
}