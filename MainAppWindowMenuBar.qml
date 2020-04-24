import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.2

MenuBar {
    Menu {
        title: qsTr("&File")
        Action {
            text: qsTr("&New")
        }
        Action {
            text: qsTr("&Open")
            onTriggered: {
                fileManager.fileOperations('open', 'Open a GPX file OK');
            }
        }
        Action {
            text: qsTr("&Save")
            onTriggered: {
                fileManager.fileOperations('save');
            }
        }
        Action {
            text: qsTr("Save &As")
            onTriggered: {
                fileManager.fileOperations('saveas');
            }
        }
        Action {
            text: qsTr("&Close")
            onTriggered:{
                fileManager.fileOperations('close');
            }
        }

        Action {
            text: qsTr("&Quit")
            //TODO an "are you sure mechanism
            onTriggered: Qt.quit();
        }
    }
    Menu {
        title: qsTr("&Help")
        Action {
            text: qsTr("Help")
        }
        Action {
            text: qsTr("&About")
        }
    }
}
