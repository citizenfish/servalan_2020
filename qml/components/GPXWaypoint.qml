import QtQuick 2.0
import QtPositioning 5.8
import QtLocation 5.9
import "qrc:/javascript/storageFunctions.js" as DB
import "qrc:/javascript/mapFunctions.js" as MF


MapItemView{


    model: wpModel
    delegate: MapQuickItem {
            sourceItem: Rectangle {
                width: 20
                height: 20
                color: "#2ad3f9"
                //radius: 15
                opacity: 0.8

                MouseArea {
                    drag.target: parent
                    anchors.fill : parent
                    property bool dragActive: drag.active;

                    onDragActiveChanged: {
                        parent.color = 'red';
                        parent.opacity = 0.3;
                        if(!drag.active){
                            parent.color = "#2ad3f9"
                        }
                    }


                }

            }
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            coordinate : QtPositioning.coordinate(lat, lon)


        }
}
