import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3


ToolBar {

    RowLayout {
        Button {
            text: qsTr("Controls")
            onClicked: {
                if(sideBar.visible)
                    sideBar.close()
                else
                    sideBar.open()
            }
        }
        Button {
            text: qsTr("Profile")
            onClicked: mapProfileWindow.show()
        }
        Button {
            text: qsTr("Edit")
            onClicked: mainApplicationWindow.toggleEditMode();

        }

        Button{
            text: qsTr("TEST")

        }
    }


}