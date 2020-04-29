import QtQuick 2.0
import QtQuick.Window 2.0

Window {

    height: 200
    color: "#000000"
    width: 800
    visible: false
    property var graphXMargin: 20;
    property var graphYMargin: 20;
    property var graphAxisWidth: 2;
    Row {

        id: graphArea
        anchors.fill: parent
        anchors.centerIn: parent

        Rectangle {
            id: profileContainer
            width: parent.width - 120
            height: parent.height
            color: "white"

            Canvas {
                id: profileCanvas
                anchors.centerIn: parent
                width: parent.width - 10
                height: parent.height - 10

                onPaint: {
                    var ctx = getContext("2d");
                    //ctx.fillStyle = Qt.rgba(1,1,1,1);
                    //ctx.fillRect(0,0,width,height);

                    //axis
                    ctx.strokeStyle = "#000000";
                    ctx.lineWidth = graphAxisWidth;
                    ctx.beginPath();
                    ctx.moveTo(graphXMargin,graphYMargin);

                    ctx.lineTo(graphXMargin,height - graphYMargin);
                    ctx.lineTo(width - graphXMargin,height - graphYMargin);
                    ctx.stroke();
                }
            }
        }

        Rectangle{
            id:statsArea
            width: parent.width - 680 > 100 ? parent.width - 680 : 120
            height:parent.height
            color: "grey"
        }
    }

}
