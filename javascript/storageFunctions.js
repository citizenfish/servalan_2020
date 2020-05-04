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

    //mark our gpx as changed so we know to propmpt for save
    mainApplicationWindow.gpxHasChanged = true;

    var ret_var,
        undo_command = {},
        redo_command = {};

    mode = mode === undefined ? 'do' : mode;
    switch (command) {

    case 'addMarker':
        ret_var = gpxModel.addMarker(parameters.coordinate);
        undo_command = {"command" : "deleteMarkerAtIndex", "parameters" :{"index" : ret_var + 1 }};
        redo_command = {"command" : "addMarker",  "parameters" :{"coordinate" : parameters.coordinate}};
        break;

    case 'deleteMarkerAtIndex':
        ret_var = gpxModel.deleteMarkerAtIndex(parameters.index);
        undo_command = {"command" : "addMarkerAtIndex", "parameters" :{"index" : parameters.index - 1, "coordinate" : ret_var}};
        redo_command = {"command" : "deleteMarkerAtIndex", "parameters" : {"index" : parameters.index}};
        break;

    case 'addMarkerAtIndex':
         ret_var = gpxModel.addMarkerAtIndex(parameters.coordinate, parameters.index);
         undo_command = {"command" : "deleteMarkerAtIndex", "parameters" : {"index" : ret_var.index}};
         redo_command = {"command":  "addMarkerAtIndex", "parameters" : {"coordinate" : parameters.coordinate, "index" : parameters.index}};
         break;

    case 'updateMarkerLocation':
        ret_var = gpxModel.updateMarkerLocation(parameters.coordinate, parameters.itemDetails);
        undo_command = {"command" : "updateMarkerLocation", "parameters" : {"coordinate" : parameters.oCoordinate, "itemDetails" : parameters.itemDetails}};
        redo_command = {"command" : "updateMarkerLocation", "parameters" : {"coordinate" : parameters.coordinate, "itemDetails" : parameters.itemDetails}};
        break;

    case 'addWaypoint':
        wpModel.append({lat : parameters.coordinate.latitude, lon: parameters.coordinate.longitude, description: "Marker"});
        undo_command = {"command" : "deleteWaypoint", "parameters" :{"index" : wpModel.count - 1}};
        redo_command = {"command" : "addWaypoint", "parameters" : {"coordindate" : parameters.coordinate}};
        break;

    case 'deleteWaypoint':
        var item  = wpModel.get(parameters.index);
        wpModel.remove(parameters.index, 1);
        undo_command = {"command" : "addWaypoint", "parameters" :{"coordinate" : QtPositioning.coordinate(item.lat, item.lon)}};
        redo_command = {"command" : "deleteWaypoint", "parameters" : {"index" : parameters.index}};
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
        console.log("Command " + i +" stack " + JSON.stringify(commandStack[i]));
    }
}
