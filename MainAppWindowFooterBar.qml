import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

StatusBar {

    id: root
    property string zoomStatusText
    property string locationStatusText
    property string editStatusText

    RowLayout {

        anchors.fill: parent

        Label {
            text: root.zoomStatusText
        }

        Label {
            text: root.locationStatusText
        }

        Label {
            text: root.editStatusText
        }
    }


}
