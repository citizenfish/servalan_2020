function marker_dragged() {
    var coord = mapView.toCoordinate(Qt.point(x,y));
    DB.modelCommandExecute('updateMarkerLocation', {"coordinate" : coord, "itemDetails" : itemDetails, "oCoordinate" : mDetails});

}

function waypoint_dragged(index, oCoordinate) {
    var coord = mapView.toCoordinate(Qt.point(x,y));
    DB.modelCommandExecute('updateWayPointLocation', {"old_coordinate" : oCoordinate, "index" : index, "mode" : "log_for_undo", "new_coordinate" : coord});
}

function marker_clicked(index, mouseButton) {

    if(mouseButton === Qt.RightButton){
        //Will delete here
        console.log("right button");
        return;
    }

    // Left button below here
    // Here we are selecting map markers on the line to facilitate segment save, segment delete and segment insert
    index += gpxModel.get_edit_marker_offset();

    if(selectedStartMarker === -1){
        selectedStartMarker = index;
    } else {
        if(index < selectedStartMarker) {
            selectedEndMarker = selectedStartMarker
            selectedStartMarker = index
        } else {
                selectedEndMarker = index;
        }
    }

    gpxModel.forceRedraw(selectedStartMarker, selectedEndMarker);
}

function marker_double_clicked() {
    DB.modelCommandExecute('deleteMarkerAtIndex', {"index" : itemDetails});
}

function mapClicked(x,y, button) {
    var coord = mapView.toCoordinate(Qt.point(x,y))

    //Reset any marker selections
   if(selectedStartMarker > -1){
        var s1 = selectedStartMarker;
        var s2 = selectedEndMarker;

        selectedEndMarker = -1;
        selectedStartMarker = -1;
        gpxModel.forceRedraw(s1, s2);
    return;
   }

    //Route marker
    if(button === Qt.LeftButton) {
        DB.modelCommandExecute('addMarker', {"coordinate" : coord});
        return;
       }

    //Waypoint
    if(button === Qt.RightButton){
        //wpModel.append({lat : coord.latitude, lon: coord.longitude, description: "Marker"});
        DB.modelCommandExecute('addWaypoint', {"coordinate" : coord});
        return;
    }

}

function mapDoubleClicked(x,y,button){
    var coord = mapView.toCoordinate(Qt.point(x,y))
    mapView.center = coord
    mapView.zoomLevel++
}


function zoom(mode){
    if(mode === 'in') {
        appMapView.mapView.zoomLevel++
    } else {
        appMapView.mapView.zoomLevel--
    }
}

function redraw_mapmarkers(s1,s2) {
    var range = s2 > -1 ? s2 - s1 - 1: -1;
    gpxModel.forceRedraw(s1, range);
}

function toggleEditMode(){
    if(mainApplicationWindow.editMode === 'Off'){
         //gpxModel.setEditLocation(gpxModel.rowCount());
         mainApplicationWindow.editMode = 'On';
    }
    else{
        mainApplicationWindow.editMode = 'Off';
    }
    update_edit_status(this.editMode);
}

function update_zoom_status(){
    footerBar.zoomStatusText = 'Zoom ' + Math.round(mapView.zoomLevel);
}

function update_location_status(){
    footerBar.locationStatusText = 'Lonlat(' + mapView.center.longitude.toFixed(3) + ',' + mapView.center.latitude.toFixed(3) +')';
}

function update_edit_status(text) {
    footerBar.editStatusText = "Edit Mode: " + text;
}



