// Programme exemple 4
# midi.py
def exportMIDI(filename, tempo):
    # Implémenter la fonction Python pour exporter le fichier MIDI en utilisant les paramètres filename et tempo
    pass

# main.qml
import sys
import QtQuick 2.0
import QtQuick.Controls 1.4
import midi

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
            midi.exportMIDI("output.midi", 120)
        }
    }
}