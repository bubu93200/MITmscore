//Proegrammeexemple 1

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

//Programme exemple 3
# midi.py
def exportMIDI():
    # Implémenter la fonction Python pour exporter le fichier MIDI
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
            midi.exportMIDI()
        }
    }
}


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

// programme exemple 5
# song.py
def getSongInfo(filename):
    # Implémenter la fonction Python pour obtenir les informations de la chanson en utilisant le paramètre filename
    return ("Title", "Artist", "Album")

# main.qml
import sys
import QtQuick 2.0
import QtQuick.Controls 1.4
import song

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Song Info")

    Button {
        id: infoButton
        anchors.centerIn: parent
        text: qsTr("Get Song Info")
        onClicked: {
            var songInfo = song.getSongInfo("input.mp3")
            console.log("Title: " + songInfo[0])
            console.log("Artist: " + songInfo[1])
            console.log("Album: " + songInfo[2])
        }
    }
}

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


// Scanner les entrée midi
import QtQuick 2.12
import QtQuick.Window 2.12
import MuseScore 2.0

Window {
    id: root
    visible: true
    width: 640
    height: 480

    property var midiInputs: []

    Component.onCompleted: {
        // Scanner toutes les entrées MIDI
        midiInputs = MuseScore.Midi.inputs
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Afficher la boîte de dialogue MidiInputDialog.qml
            var dialog = Qt.createComponent("qrc:/MidiInputDialog.qml");
            if (dialog.status === Component.Ready) {
                dialog.createObject(root, {"midiInputs": midiInputs});
            } else if (dialog.status === Component.Error) {
                console.error(dialog.errorString());
            }
        }
    }
}


// Le programme scanner les entrée midi utilise une boite de dialogue dans un fichier MidiInputDialog.qml
import QtQuick 2.12
import QtQuick.Controls 2.12

Dialog {
    id: dialog
    width: 400
    height: 300

    property var midiInputs

    ListModel {
        id: midiInputsModel
    }

    ComboBox {
        model: midiInputsModel
        onCurrentIndexChanged: {
            // Traiter la sélection de l'utilisateur ici
            console.log("Sélectionné : " + midiInputsModel.get(currentIndex).name)
        }
    }

    Component.onCompleted: {
        // Ajouter toutes les entrées MIDI scannées au modèle
        for (var i = 0; i < midiInputs.length; i++) {
            midiInputsModel.append({"name": midiInputs[i]})
        }
    }
}

// Ecoute d'une entrée midi
import sys
from musescore import MidiInput

# Créer un objet pour la lecture MIDI
midi_input = MidiInput()

# Configurer les entrées MIDI à écouter
input_devices = midi_input.get_input_devices()

# Afficher les entrées MIDI disponibles
print("Entrées MIDI disponibles:")
for index, device in enumerate(input_devices):
    print("{}: {}".format(index, device))

# Demander à l'utilisateur de choisir une entrée MIDI
selected_device = int(input("Sélectionnez une entrée MIDI: "))

# Configurer la source MIDI sélectionnée
midi_input.set_input_device(input_devices[selected_device])

# Définir la fonction de rappel pour les données MIDI
def midi_data_callback(event):
    print("Données MIDI reçues: {}".format(event))

# Enregistrer la fonction de rappel pour les données MIDI
midi_input.register_callback(midi_data_callback)

# Démarrer l'écoute MIDI
midi_input.start_listening()

# Attendre jusqu'à ce que l'utilisateur interrompe l'exécution du programme
try:
    while True:
        pass
except KeyboardInterrupt:
    # Arrêter l'écoute MIDI
    midi_input.stop_listening()
    sys.exit()


// ecouter une entrée midi
import musescore

midi_input = musescore.MidiInput()
midi_input.start()

with open("midi_recording.mid", "wb") as file:
    while True:
        event = midi_input.get_event()
        if event is None:
            break
        file.write(event.data)

midi_input.stop()

// écouter une entrée midi
from musescore import MidiInput

def on_note_on(note_number, velocity, channel):
    # Enregistrer les données de la note dans un fichier
    with open("midi_data.txt", "a") as f:
        f.write(f"Note: {note_number}, Velocity: {velocity}, Channel: {channel}\n")

# Créer une instance de la classe MidiInput
midi_input = MidiInput()

# Attacher la fonction on_note_on à l'événement onNoteOn
midi_input.onNoteOn.connect(on_note_on)

# Démarrer l'écoute des entrées MIDI
midi_input.start()

# Attendre l'arrêt de l'écoute MIDI
midi_input.wait()


// Vérifier si une note jouée est correcte en qml
import QtQuick 2.15
import MuseScore 3.0

ScoreView {
    id: scoreView

    // Charger la partition à partir d'un fichier
    score: Score {
        id: score
        fileName: "partition.mscz"
    }

    MidiInput {
        id: midiInput
        onNoteOn: {
            // Vérifier si la note jouée correspond à la note attendue dans la partition
            if (noteNumber == score.notes[currentNote].pitch && channel == 0) {
                currentNote++
            }
        }
    }

    Component.onCompleted: {
        midiInput.start()
        currentNote = 0
    }
}
