Code a plugin for MuseScore 3.5 with a button start on a panel which export current score or selected score to a midi file. On a text zone, I can modify repertory of midi file. On another text zone, I can modify midi file name

As an AI language model, I cannot directly code a plugin for MuseScore 3.5, but I can provide you with a general framework to achieve the desired functionality. Here are the steps you can follow:

    Create a new plugin in MuseScore 3.5 and add a panel with a button to export the current score or selected score to a MIDI file. You can do this using the Qt framework for GUI programming.

    When the user clicks the button, retrieve the selected or current score and convert it to a MIDI file format. You can use the MusicXML library included with MuseScore to do this.

    Provide two text fields in the panel to allow the user to modify the directory and name of the MIDI file to be exported. You can use the Qt framework to create and manage the text fields.

    When the user modifies the text fields, update the corresponding values in your plugin's internal data structure.

    When the user clicks the export button, use the MIDI library included with MuseScore to write the MIDI data to the specified file.

Here is some sample code that demonstrates how to create a simple plugin that exports the current score to a MIDI file:

python

import os
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLineEdit, QPushButton
from PyQt5.QtCore import Qt
from music21 import midi
from music21 import stream


class ExportMIDIPlugin(QWidget):
    def __init__(self):
        super().__init__()

        # Create UI elements
        self.repertory_textbox = QLineEdit()
        self.midi_name_textbox = QLineEdit()
        self.export_button = QPushButton("Export MIDI")

        # Set initial values
        self.repertory_textbox.setText("/home/user/midi/")
        self.midi_name_textbox.setText("exported.mid")

        # Connect UI elements to functions
        self.export_button.clicked.connect(self.export_midi)

        # Create layout and add UI elements
        vbox = QVBoxLayout()
        hbox1 = QHBoxLayout()
        hbox2 = QHBoxLayout()

        hbox1.addWidget(QLabel("Repertory"))
        hbox1.addWidget(self.repertory_textbox)
        hbox2.addWidget(QLabel("Midi name"))
        hbox2.addWidget(self.midi_name_textbox)

        vbox.addLayout(hbox1)
        vbox.addLayout(hbox2)
        vbox.addWidget(self.export_button)

        self.setLayout(vbox)

    def export_midi(self):
        # Get current score and convert it to a MIDI file
        current_score = self.currentScore()
        midi_data = midi.translate.music21ObjectToMidiFile(current_score)

        # Get file name from UI elements
        repertory = self.repertory_textbox.text()
        midi_name = self.midi_name_textbox.text()

        # Write MIDI file to disk
        midi_path = os.path.join(repertory, midi_name)
        with open(midi_path, 'wb') as midi_file:
            midi_data.writestr(midi_file)

This is just a starting point for your plugin, and you may need to modify it to fit your specific requirements. You should also consult the MuseScore API documentation for more information on how to interact with the MuseScore application from your plugin.
bruno.donati@hotmail.fr
Code a qml plugin for MuseScore with a button start on a panel which export current score or selected score to a midi file. On a text zone, I can modify repertory of midi file. On another text zone, I can modify midi file name

As an AI language model, I can provide you with a general framework to create a QML plugin for MuseScore that exports a score to a MIDI file with options to modify the directory and file name. Here are the steps you can follow:

    Create a new QML plugin in MuseScore and add a panel with a button to export the current score or selected score to a MIDI file. You can do this using the Button and Panel QML components.

    When the user clicks the button, retrieve the selected or current score and convert it to a MIDI file format. You can use the Midi object provided by MuseScore to do this.

    Provide two text fields in the panel to allow the user to modify the directory and name of the MIDI file to be exported. You can use the TextField QML component to create and manage the text fields.

    When the user modifies the text fields, update the corresponding values in your plugin's internal data structure.

    When the user clicks the export button, use the Midi object provided by MuseScore to write the MIDI data to the specified file.

Here is some sample code that demonstrates how to create a simple QML plugin that exports the current score to a MIDI file:

qml

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
            // Get current score and convert it to a MIDI file
            var currentScore = MuseScore.currentScore()
            var midiData = new Midi.MidiFile(currentScore)

            // Get file name from UI elements
            var repertory = repertoryField.text
            var midiName = midiNameField.text
            var midiPath = repertory + midiName

            // Write MIDI file to disk
            midiData.writeFile(midiPath)
        }
    }
}

This is just a starting point for your plugin, and you may need to modify it to fit your specific requirements. You should also consult the MuseScore QML plugin documentation for more information on how to interact with the MuseScore application from your plugin.
bruno.donati@hotmail.fr
Rewrite code to only export selected notes from current score

Sure! Here's an updated version of the code that exports only the selected notes from the current score:

qml

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

In this version of the code, we retrieve the selected notes from the current score using the MuseScore.curScore.selection.notes property. We then pass these notes to the Midi.MidiFile constructor to create the MIDI data for export. The remaining steps for getting the file name and writing the MIDI file to disk are the same as in the previous version of the code.

Note that if there are no notes selected, this code will export an empty MIDI file. You may want to add some additional logic to check if there are any selected notes and display an error message if there are not.
