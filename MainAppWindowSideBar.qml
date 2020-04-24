import QtQuick 2.0
import QtQuick.Controls 2.5

Drawer {
    width: 240
    y: mainApplicationWindow.header.height + mainApplicationWindow.menuBar.height
    height: mainApplicationWindow.height - mainApplicationWindow.header.height -mainApplicationWindow.menuBar.height

    Label {
                text: "Toolbox"
                anchors.centerIn: parent
            }
}
