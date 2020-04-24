import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

Window {

    height: 200
    width: 800


    RowLayout {

        ComboBox {
            id: mapChooseCombo
            currentIndex: 1
            model: ["Openstreetmap", "Mapbox"]
        }

        Button {
            text: "Choose Map"
            MouseArea {
                anchors.fill: parent
                onClicked: {


                    if(mapChooseCombo.currentValue === 'Mapbox') {
                        appMapView.mapView.plugin = appMapView.mapboxPlugin;
                    }

                    if(mapChooseCombo.currentValue === 'Openstreetmap'){
                        appMapView.mapView.plugin = appMapView.osmPlugin;
                    }

                    mapChooserWindow.visible = false;
                    appMapView.visible = true;
                }
            }
        }

    }
}
