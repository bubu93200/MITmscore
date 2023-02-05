













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
