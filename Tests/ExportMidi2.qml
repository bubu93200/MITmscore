// written by chatgpt
import QtQuick 2.0
import MuseScore 3.5

Panel {
    id: exportPanel
    title: "Export MIDI"

    // UI elements
    TextField {
        id: repertoryField
        placeholderText: "/home/user/midi/"
    }
    TextField {
        id: midiNameField
        placeholderText: "exported.mid"
    }
    Button {
        text: "Export"
        onClicked: {
            // Get selected notes and convert them to a MIDI file
            var selectedNotes = MuseScore.curScore.selection.notes
            var midiData = new Midi.MidiFile(selectedNotes)

            // Get file name from UI elements
            var repertory = repertoryField.text
            var midiName = midiNameField.text
            var midiPath = repertory + midiName

            // Write MIDI file to disk
            midiData.writeFile(midiPath)
        }
    }
}
