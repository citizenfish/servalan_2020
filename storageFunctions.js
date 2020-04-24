

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
        undo_command = {"command" : "deleteMarkerAtIndex", "parameters" :{"index" : ret_var}};
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

