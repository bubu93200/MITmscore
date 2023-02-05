// Programme exemple 6
# export.py
from MuseScore import Score

def exportMIDI(filename):
    # Implémenter la fonction Python pour exporter la partition courante en MIDI
    # Utiliser le paramètre filename pour définir le nom du fichier
    success = True
    message = "Exported successfully"
    try:
        # Utiliser la classe Score pour accéder à la partition courante
        score = Score()
        score.saveMIDI(filename)
    except:
        success = False
        message = "Export failed"
    return (success, message)

# main.qml
import sys
import QtQuick 2.0
import QtQuick.Controls 1.4
import export

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Export MIDI")

    Button {
        id: exportButton
        anchors.centerIn: parent
        text: qsTr("Export MIDI")
        onClicked: {
            var result = export.exportMIDI("output.mid")
            if (result[0]) {
                console.log("Success: " + result[1])
            } else {
                console.log("Failure: " + result[1])
            }
        }
    }
}