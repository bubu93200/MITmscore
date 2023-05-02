```cpp

#include <iostream>
#include <cstdlib>
#include <vector>
#include <rtmidi/RtMidi.h>
#include <fstream>

int main() {
    RtMidiOut midiOut;
    std::vector<unsigned char> message;
    std::string filename = "example.mid";

    // Ouvrir le port MIDI
    try {
        midiOut.openVirtualPort();
    } catch (RtMidiError &error) {
        std::cerr << "Erreur lors de l'ouverture du port MIDI : " << error.getMessage() << std::endl;
        exit(EXIT_FAILURE);
    }

    // Initialiser les données du fichier MIDI
    std::vector<unsigned char> header = {0x4d, 0x54, 0x68, 0x64, 0x00, 0x00, 0x00, 0x06, 0x00, 0x01, 0x00, 0x01, 0x00, 0x80};
    std::vector<unsigned char> trackHeader = {0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0x00};
    std::vector<unsigned char> trackData;

    // Ajouter des notes à la piste MIDI
    unsigned char channel = 0; // canal MIDI sur lequel les notes seront jouées
    unsigned char note = 60; // note MIDI (60 = C4)
    unsigned char velocity = 127; // vélocité de la note (0 = silence, 127 = maximum)
    unsigned long timestamp = 0; // temps en ticks depuis le début de la piste
    unsigned long duration = 960; // durée de la note en ticks (960 = une noire)
    message.push_back(0x90 + channel);
    message.push_back(note);
    message.push_back(velocity);
    midiOut.sendMessage(&message);
    message.clear();
    message.push_back(0x80 + channel);
    message.push_back(note);
    message.push_back(0x00);
    midiOut.sendMessage(&message);
    message.clear();
    trackData.push_back(0x00); // Delta time (temps écoulé depuis la dernière note)
    trackData.push_back(0x90 + channel);
    trackData.push_back(note);
    trackData.push_back(velocity);
    trackData.push_back(0x00); // Delta time
    trackData.push_back(0x80 + channel);
    trackData.push_back(note);
    trackData.push_back(0x00);

    // Ajouter les données de la piste au fichier MIDI
    unsigned long trackLength = trackData.size() + trackHeader.size() - 8;
    trackHeader[4] = trackLength >> 24;
    trackHeader[5] = (trackLength >> 16) & 0xFF;
    trackHeader[6] = (trackLength >> 8) & 0xFF;
    trackHeader[7] = trackLength & 0xFF;
    trackData.insert(trackData.begin(), trackHeader.begin(), trackHeader.end());

    // Écrire les données dans le fichier MIDI
    std::ofstream outputFile(filename.c_str(), std::ios::out | std::ios::binary);
    if (!outputFile.is_open()) {
        std::cerr << "Erreur lors de l'ouverture du fichier MIDI : " << filename << std::
        exit(EXIT_FAILURE);
    }
    outputFile.write((const char *)&header[0], header.size());
    outputFile.write((const char *)&trackData[0], trackData.size());
    outputFile.close();

    // Fermer le port MIDI
    midiOut.closePort();

    std::cout << "Le fichier MIDI a été créé avec succès : " << filename << std::endl;

    return 0;

```
