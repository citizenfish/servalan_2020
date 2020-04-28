import QtQuick 2.0
import QtLocation 5.14
import "storageFunctions.js" as DB
import "mapFunctions.js" as MF

MapPolyline {
    line.width: 8
    path: gpxModel.path
    line.color: 'grey'
    opacity: 0.8

    MouseArea{
        id: polyLineMouse
        enabled: mainApplicationWindow.editMode === 'On' ? true : false
        anchors.fill: parent
        //hoverEnabled: true //can't use this as it takes bounding box of line

        onEntered: {
            //when we enter the line we show the marker handles to allow editing
            //this is currently triggered with a click
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
