import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../../javascript/mapFunctions.js" as MF

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
            onClicked: MF.toggleEditMode();

        }

        Button{
            text: qsTr("Add Height")
            onClicked: {

                var changed = gpxModel.addHeightToPath(0);
                console.log("Added " + changed + " height points");
            }
        }
    }


}
