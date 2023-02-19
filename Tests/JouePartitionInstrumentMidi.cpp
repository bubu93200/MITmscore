//Programme écrit pas chatgpt avec Musescore 3.0

#include <iostream>
#include <cstring>
#include "awl/midi.hpp"
#include "mscore/midi/midi.h"
#include "mscore/score.h"
#include "mscore/selection.h"

using namespace std;

int main(int argc, char* argv[]) {
    // Initialisation de l'API MusScore
    Ms::Score* score = new Ms::Score;
    Ms::init(score);

    // Récupération de la partition courante
    Ms::Selection* selection = new Ms::Selection;
    Ms::ScoreView* view = Ms::ScoreView::getFocus();
    if (view) {
        view->getSelection(*selection);
    }

    // Configuration du périphérique MIDI
    Awl::Midi* midi = new Awl::Midi;
    midi->setOutputPort(0);

    // Récupération des données MIDI de la partition
    Ms::MidiFile midiFile;
    midiFile.createFromScore(*score, *selection);
    unsigned char* midiData = midiFile.getTrackData(0);
    int midiSize = midiFile.getTrackSize(0);

    // Envoi des données MIDI vers le périphérique
    midi->sendRawData(midiData, midiSize);

    // Nettoyage des ressources
    delete selection;
    delete score;
    delete midi;

    return 0;
}
