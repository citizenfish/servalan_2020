import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

Window {

    height:200
    color: "#f1ecec"
    width: 600
    modality: Qt.ApplicationModal

    property var mapLookup: { "Openstreetmap":      {"plugin" : appMapView.osmPlugin, "image" :"qrc:/images/openstreetmap.png"},
                              "Zoomstack Light":    {"plugin" : appMapView.zoomStackLightPlugin, "image" :"qrc:/images/zoomstack-light.png"},
                              "Zoomstack Road":     {"plugin" : appMapView.zoomStackRoadPlugin, "image" :"qrc:/images/zoomstack-road.png"},
                              "Zoomstack Outdoor":  {"plugin" : appMapView.zoomStackOutdoorPlugin, "image" :"qrc:/images/zoomstack-outdoor.png" }}
    RowLayout {
        x: 301
        y: 100
        width: 202
        height: 40

        ComboBox {
            id: mapChooseCombo
            width: 350
            rightPadding: 10
            Layout.rightMargin: 0
            Layout.leftMargin: 0
            Layout.topMargin: 0
            currentIndex: 0
            model: ["Openstreetmap", "Zoomstack Light", "Zoomstack Road", "Zoomstack Outdoor"]
            onCurrentValueChanged: {
                chooserButton.text  = "Use " + currentValue;
                mapImagePanel.source = mapLookup[currentValue].image;
            }
        }



    }

    Button {
        id:chooserButton
        x: 300
        y: 146
        text: "Use Openstreetmap"
        MouseArea {
            anchors.fill: parent
            onClicked: {

                appMapView.mapView.plugin = mapLookup[mapChooseCombo.currentValue].plugin;
                mapChooserWindow.visible = false;
                appMapView.visible = true;
            }
        }
    }

    Frame {
        id: frame
        x: 38
        y: 21
        width: 200
        height: 158

        Image {
            id: mapImagePanel
            source: "qrc:/images/openstreetmap.png"
            width:parent.width
            height: parent.height
        }
    }

    Text {
        id: element
        x: 270
        y: 21
        width: 264
        height: 82
        text: qsTr("Servalan allows you to use maps in Openstreetmap or OS Zoomstack format. You need to select the map type prior to loading a GPX file. ")
        verticalAlignment: Text.AlignTop
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WordWrap
        font.pixelSize: 12
    }
}
