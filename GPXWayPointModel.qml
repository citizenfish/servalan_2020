import QtQuick 2.0

//Model for waypoint data
ListModel{

    onRowsInserted: {
        console.log('Stuff happend in the model')
    }
}
