import QtQuick 2.0
import QtLocation 5.14
import "storageFunctions.js" as DB
import "mapFunctions.js" as MF

MapPolyline {
    line.width: 5
    path: gpxModel.path
    line.color: 'white'
    MouseArea{
        id: polyLineMouse
        enabled: mainApplicationWindow.editMode == 'On' ? true : false
        anchors.fill: parent
        //hoverEnabled: true
        onEntered: {
            //when we enter the line we show the marker handles to allow editing
            var index = MF.get_index(gpxLine,mouseX,mouseY);
            gpxModel.setEditLocation(index);

        }


        onPressAndHold: {
            var index = MF.get_index(gpxLine,mouseX,mouseY);
            //we have to convert the click into a coordinate on map, not in the line space
            var mapCoord = gpxLine.mapToItem(mapView,mouseX,mouseY);
            var coord = mapView.toCoordinate(Qt.point(mapCoord.x,mapCoord.y))
            DB.modelCommandExecute('addMarkerAtIndex', {"coordinate" : coord, "index" : index});
        }


    }


}
