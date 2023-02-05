//Programmeexemple 1

import QtQuick 2.0
import QtQuick.Controls 1.4

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
            // Appeler la fonction Python pour exporter le fichier MIDI
            exportMIDI()
        }
    }
}