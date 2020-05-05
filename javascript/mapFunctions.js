function marker_dragged() {
    var coord = mapView.toCoordinate(Qt.point(x,y));
    DB.modelCommandExecute('updateMarkerLocation', {"coordinate" : coord, "itemDetails" : itemDetails, "oCoordinate" : mDetails});

}

function marker_double_clicked() {
    DB.modelCommandExecute('deleteMarkerAtIndex', {"index" : itemDetails});
}

function mapClicked(x,y, button) {
    var coord = mapView.toCoordinate(Qt.point(x,y))

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


