import QtQuick 2.0

//Model for waypoint data
ListModel{

    onRowsInserted: {

        console.log('A waypoint got added ');
    }

    onRowsRemoved:  {
        console.log('A waypoint got removed');
    }

    onRowsMoved: {
        console.log('A waypoint got moved')
    }
}
