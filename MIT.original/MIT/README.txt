This (probably linux-only) plugin (for MuseScore 2.0) takes input from a MIDI instrument and colors notes while you play from blue (note and rhythm are perfect) to red (bad note or bad rhythm).
The score must have been exported in MIDI format before.
The plugin needs aplaymidi and aconnect (alsa-utils package in ubuntu), as well as qsynth (fluid synth) in order to ear the instrument.
The plugin compares the output of aplaymidi (which reads the midi file) with the output of the instrument. For each note, it computes the delay between the beginning of the note in the midi file and the beginning of the note you played, and the same for the end of the note. Then it colors the note depending on these delays.

You must edit the "MidiInstrumentTraining.qml" file to set the default settings, especially the folder in which the plugin is installed (pluginsPath) and the folder in which midi files are stored (midiPath).

Some settings can be changed in the plugin interface (you can also permanently change the default values in the MidiInstrumentTraining.qml file):
- Score channel : if the current score as multiple parts, you can select the one you want to play (0 is the first part, 1 is the second, ...)
- Midi Instrument name: The name of the midi instrument in order to be able to connect its output to the plugin and to qsynth. You can use "aconnect -i" (with and without connecting the instrument) to find its name. If you change the name, you should click on "restart synth" to be able to ear the instrument.
- Midi Instrument channel: It's probably always 0...
- WEIGHT START: This corresponds to the weight attributed to the delay between the score and the instrument at the beginning of the note in the computation of the color.
- WEIGHT END (+): This corresponds to the weight attributed to the delay between the score and the instrument at the end of the note if the instrument is late.
- WEIGHT END (-): This corresponds to the weight attributed to the delay between the score and the instrument at the end of the note if the instrument ends in advance. For wind instruments, the player sometimes needs to breath between two notes, so there should be more tolerance for a negative delay than a positive one... For other instruments, "WEIGHT END (-)" should probably be equal to "WEIGHT END (+)".
- MAX BADNESS: This correspond to the maximum weighted delay considered for the coloration (red note). You should increase it if it is too difficult to obtain blue notes and decrease it if it is too easy...
