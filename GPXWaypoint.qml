import QtQuick 2.0
import QtPositioning 5.8
import QtLocation 5.9
import "storageFunctions.js" as DB
import "mapFunctions.js" as MF


MapItemView{


    model: wpModel
    delegate: MapQuickItem {
            sourceItem: Rectangle {
                width: 14
                height: 14
                color: "#2ad3f9"
                radius: 7
            }
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            coordinate : QtPositioning.coordinate(lat, lon)
        }
}
