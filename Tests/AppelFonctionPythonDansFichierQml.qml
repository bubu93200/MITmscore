//Program exemple 2
import sys
import QtQuick 2.0
import QtQuick.Controls 1.4
from PyQt5.QtCore import QObject, pyqtSlot

class PythonCaller(QObject):
    @pyqtSlot()
    def exportMIDI(self):
        # Implémenter la fonction Python pour exporter le fichier MIDI
        pass

caller = PythonCaller()

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("MIDI Export")

    Button {
        id: exportButton
        anchors.centerIn: parent
        text: qsTr("Export MIDI")
        onClicked: {
            caller.exportMIDI()
        }
    }
}