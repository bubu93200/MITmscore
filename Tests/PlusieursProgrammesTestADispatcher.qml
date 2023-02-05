













// Scanner les entr�e midi
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
        // Scanner toutes les entr�es MIDI
        midiInputs = MuseScore.Midi.inputs
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Afficher la bo�te de dialogue MidiInputDialog.qml
            var dialog = Qt.createComponent("qrc:/MidiInputDialog.qml");
            if (dialog.status === Component.Ready) {
                dialog.createObject(root, {"midiInputs": midiInputs});
            } else if (dialog.status === Component.Error) {
                console.error(dialog.errorString());
            }
        }
    }
}


// Le programme scanner les entr�e midi utilise une boite de dialogue dans un fichier MidiInputDialog.qml
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
            // Traiter la s�lection de l'utilisateur ici
            console.log("S�lectionn� : " + midiInputsModel.get(currentIndex).name)
        }
    }

    Component.onCompleted: {
        // Ajouter toutes les entr�es MIDI scann�es au mod�le
        for (var i = 0; i < midiInputs.length; i++) {
            midiInputsModel.append({"name": midiInputs[i]})
        }
    }
}

// Ecoute d'une entr�e midi
import sys
from musescore import MidiInput

# Cr�er un objet pour la lecture MIDI
midi_input = MidiInput()

# Configurer les entr�es MIDI � �couter
input_devices = midi_input.get_input_devices()

# Afficher les entr�es MIDI disponibles
print("Entr�es MIDI disponibles:")
for index, device in enumerate(input_devices):
    print("{}: {}".format(index, device))

# Demander � l'utilisateur de choisir une entr�e MIDI
selected_device = int(input("S�lectionnez une entr�e MIDI: "))

# Configurer la source MIDI s�lectionn�e
midi_input.set_input_device(input_devices[selected_device])

# D�finir la fonction de rappel pour les donn�es MIDI
def midi_data_callback(event):
    print("Donn�es MIDI re�ues: {}".format(event))

# Enregistrer la fonction de rappel pour les donn�es MIDI
midi_input.register_callback(midi_data_callback)

# D�marrer l'�coute MIDI
midi_input.start_listening()

# Attendre jusqu'� ce que l'utilisateur interrompe l'ex�cution du programme
try:
    while True:
        pass
except KeyboardInterrupt:
    # Arr�ter l'�coute MIDI
    midi_input.stop_listening()
    sys.exit()


// ecouter une entr�e midi
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

// �couter une entr�e midi
from musescore import MidiInput

def on_note_on(note_number, velocity, channel):
    # Enregistrer les donn�es de la note dans un fichier
    with open("midi_data.txt", "a") as f:
        f.write(f"Note: {note_number}, Velocity: {velocity}, Channel: {channel}\n")

# Cr�er une instance de la classe MidiInput
midi_input = MidiInput()

# Attacher la fonction on_note_on � l'�v�nement onNoteOn
midi_input.onNoteOn.connect(on_note_on)

# D�marrer l'�coute des entr�es MIDI
midi_input.start()

# Attendre l'arr�t de l'�coute MIDI
midi_input.wait()


// V�rifier si une note jou�e est correcte en qml
import QtQuick 2.15
import MuseScore 3.0

ScoreView {
    id: scoreView

    // Charger la partition � partir d'un fichier
    score: Score {
        id: score
        fileName: "partition.mscz"
    }

    MidiInput {
        id: midiInput
        onNoteOn: {
            // V�rifier si la note jou�e correspond � la note attendue dans la partition
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
