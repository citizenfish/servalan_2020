import QtQuick 2.0
import QtLocation 5.14
import "storageFunctions.js" as DB

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
            var index = gpxLine.get_index(gpxLine,mouseX,mouseY);
            gpxModel.setEditLocation(index);

        }


        onPressAndHold: {
            var index = get_index(gpxLine,mouseX,mouseY);
            //we have to convert the click into a coordinate on map, not in the line space
            var mapCoord = gpxLine.mapToItem(mapView,mouseX,mouseY);
            var coord = mapView.toCoordinate(Qt.point(mapCoord.x,mapCoord.y))
            DB.modelCommandExecute('addMarkerAtIndex', {"coordinate" : coord, "index" : index});
        }


    }

    /*
     * get_index(id,x,y)
     *
     * id: id handle of the calling component
     * x = mouse x position
     * y = mouse y position
     *
     * This function is a horrible hack but I cannot find a better way to do it. To edit a MapPolyline you need the index of the coordinate in question.
     * But MapPolyLine does not have a method allowing you to do this.
     * So the only alternative is to do it geographically.
     * - convert the click to a coordinate
     * - find the nearest coordinate in the polyline
     * - create the index based on that
     * It is a nightmare as we iterate through the entire array each line edit. There are edge cass when we will not get the index right.
     * I look forward to QTLocation coming up with something better in the future
     *
     */

    function get_index(id,x0,y0) {

        var distance = 10000000, index = -1,x1y1,x2y2;
           /* Note well we need to convert all co-ordinates into the map co-ord system using mapToItem */
           var x0t = x0; //because we modify x0 so do not want modified value to change y0
               x0 = id.mapToItem(parent,x0,y0).x;
               y0 = id.mapToItem(parent,x0t,y0).y;

           var path = gpxLine.path; //For speed as referencing via model is slow
           for(var i=0; i < path.length - 1; i++){
               //Convert into the map co-ordinate space
               x1y1 = parent.fromCoordinate(path[i]);
               x2y2 = parent.fromCoordinate(path[i+1]);
               //Use distance from line alogorithm to find the closest line
               var dx =Math.abs( (((x2y2.y - x1y1.y) * x0) -((x2y2.x - x1y1.x) *y0) + (x2y2.x * x1y1.y) - (x2y2.y * x1y1.x)) ) / Math.sqrt(((x2y2.y -x1y1.y)*(x2y2.y -x1y1.y)) +((x2y2.x -x1y1.x) *(x2y2.x -x1y1.x)));
               if(dx < distance) {
                   distance = dx;
                   index = i;
               }

           }

           return index;
    }
}
