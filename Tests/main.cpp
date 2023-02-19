// programme écrit par chatgpt avec musescore 3.0

#include <iostream>
#include <vector>
#include <string>
#include <cmath>
#include <fstream>
#include "musescore.h"
#include "midiutil/MidiFile.h"

using namespace std;

int main() {
    // Initialisation de l'API MuseScore
    MuseScore ms;

    // Récupération de la partition courante
    Score* score = ms.getCurrentScore();

    // Conversion de la partition en données MIDI
    MidiFile midi_data;
    midi_data.addTrack(1);

    int track = 0;
    int channel = 0;
    int velocity = 100;
    int time = 0;

    for (auto part : score->getParts()) {
        for (auto note : part->getNotes()) {
            int pitch = note->getPitch();
            int duration = note->getDuration() * 4;  // Conversion en unité de temps MIDI
            midi_data.addNoteOn(track, time, channel, pitch, velocity);
            midi_data.addNoteOff(track, time + duration, channel, pitch);
            time += duration;
        }
    }

    // Écriture des données MIDI dans un fichier
    ofstream output_file("output.mid", ios::binary);
    midi_data.write(output_file);

    return 0;
}
