
function fileOperations(mode, title) {

    fileDialog.title = title || (mode + "GPX file");

    if(mode !== undefined)
        fileDialog.mode = mode;

    //Kill undo if we are working on another file
    if(mode === 'open' || mode === 'close'){
        mainApplicationWindow.commandStack =[];
        mainApplicationWindow.commandStackPointer =0;
    }

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
        fileDialog.selectExisting = false;
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

function modelCommandExecute(command, parameters, mode) {

    //mark our gpx as changed so we know to prompt for save
    mainApplicationWindow.gpxHasChanged = true;

    var ret_var,
        undo_command = {},
        redo_command = {},
        item;

    mode = mode === undefined ? 'do' : mode;
    switch (command) {

    case 'addMarker':
    case 'addMarkerOnLine':
        ret_var = gpxModel.addMarker(parameters.coordinate, parameters.append === undefined ?  true : parameters.append);
        undo_command = {"command" : "deleteMarkerAtIndex", "parameters" :{"index" : ret_var }};
        redo_command = {"command" : "addMarker",  "parameters" :{"coordinate" : parameters.coordinate}};
        break;

    case 'deleteMarkerAtIndex':
        ret_var = gpxModel.deleteMarkerAtIndex(parameters.index);
        undo_command = {"command" : "addMarker", "parameters" :{"append" : false, "coordinate" : ret_var}};
        redo_command = {"command" : "deleteMarkerAtIndex", "parameters" : {"index" : parameters.index}};
        break;

    case 'deleteMarkerRange':
        var s1 = parameters.start, s2 = parameters.end;

        appMapView.selectedStartMarker = -1;
        appMapView.selectedEndMarker = -1;

        ret_var = gpxModel.deleteMarkerRange(s1,s2);
        undo_command = {"command" : "undoMarkerDeleteRange", "parameters" : {"undo_index" : ret_var, "count" : s2 - s1 + 1, "tp_index" : s1}};
        redo_command = {"command" : "deleteMarkerRange",    "parameters" : {"start" : parameters.start, "end" : parameters.end}};
        break;

    case 'undoMarkerDeleteRange':
        console.log(JSON.stringify(parameters));
        ret_var = gpxModel.insertMarkerRangeUndo(parameters.tp_index,parameters.count, parameters.undo_index);
        undo_command = {"command" : "deleteMarkerRange",    "parameters" : {"start" : parameters.tp_index, "end" : parameters.tp_index + parameters.count}};
        redo_command = {"command" : "undoMarkerDeleteRange", "parameters" : {"undo_index" : ret_var, "count" : parameters.count, "tp_index" : parameters.tp_index}};
        break;

    case 'updateMarkerLocation':
        ret_var = gpxModel.updateMarkerLocation(parameters.coordinate, parameters.itemDetails);
        undo_command = {"command" : "updateMarkerLocation", "parameters" : {"coordinate" : parameters.oCoordinate, "itemDetails" : parameters.itemDetails}};
        redo_command = {"command" : "updateMarkerLocation", "parameters" : {"coordinate" : parameters.coordinate, "itemDetails" : parameters.itemDetails}};
        break;

    case 'addWaypoint':
        wpModel.append({lat : parameters.coordinate.latitude, lon: parameters.coordinate.longitude, description: "Marker"});
        undo_command = {"command" : "deleteWaypoint", "parameters" :{"index" : wpModel.count - 1}};
        redo_command = {"command" : "addWaypoint", "parameters" : {"coordinate" : parameters.coordinate}};
        break;

    case 'deleteWaypoint':
        item  = wpModel.get(parameters.index);
        wpModel.remove(parameters.index, 1);
        undo_command = {"command" : "addWaypoint", "parameters" :{"coordinate" : {"latitude" :item.lat, "longitude" : item.lon}}};
        redo_command = {"command" : "deleteWaypoint", "parameters" : {"index" : parameters.index}};
        break;

    case 'updateWayPointLocation':
        item = wpModel.get(parameters.index);
        if(parameters.mode === "move"){
            //wpModel.set(parameters.index,{"coordinate": parameters.new_coordinate})
            //item.coordinate = parameters.new_coordinate;
             console.log(JSON.stringify(item));
            console.log("LAT " + parameters.new_coordinate.latitude);
            wpModel.set(parameters.index, {"lat" : parameters.new_coordinate.latitude, "lon" : parameters.new_coordinate.longitude});
            console.log(JSON.stringify(item));
        }
        undo_command = {"command" : "updateWayPointLocation",  "parameters" : {"new_coordinate" : parameters.old_coordinate, "index" : parameters.index, "mode" : "move"}};
        redo_command = {"command" : "updateWayPointLocation",  "parameters" : {"new_coordinate" : parameters.new_coordinate, "index" : parameters.index, "mode" : "move"}};


        break;

    default:
        console.log("NO CLUE ABOUT "+command);
    }

    if(mode === 'do'){
        commandStackPointer += 1;
        //Check whether we have wound back into an undo
        if(commandStackPointer !== commandStack.length - 1)
            commandStack.splice(commandStackPointer, commandStack.length);

        commandStack.push({"undo_command" : undo_command, "redo_command" : redo_command});
    }


    return ret_var;
}

function modelCommandUndo(){
    if(commandStackPointer < 0) return;
    var command = commandStack[commandStackPointer];
    modelCommandExecute(command.undo_command.command, command.undo_command.parameters, 'undo');
    commandStackPointer -= 1;
}

function modelCommandRedo(){
    if(commandStackPointer > commandStack.length - 2) return;
    commandStackPointer += 1;
    var command = commandStack[commandStackPointer];
    modelCommandExecute(command.redo_command.command, command.redo_command.parameters, 'redo');

}

function dumpStack(text) {
    console.log(text + " STACK POINTER " + commandStackPointer);
    for(var i = 0; i < commandStack.length; i++){
        console.log("Command " + i +" stack " + JSON.stringify(commandStack[i]),1);
    }
}

