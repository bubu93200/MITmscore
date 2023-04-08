```cpp

#include <iostream>
#include <cstdlib>
#include <vector>
#include <rtmidi/RtMidi.h>

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
    std::vector<unsigned char> header = {0x4d, 0x54, 0x68, 0x64, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x01, 0x00, 0x80};
    std::vector<unsigned char> trackHeader = {0x4d, 0x54, 0x72, 0x6b, 0x00, 0x00, 0x00, 0x00};
    std::vector<unsigned char> trackData;

    // Ajouter une note au fichier MIDI
    unsigned char channel = 0; // canal MIDI sur lequel la note sera jouée
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

    // Ajouter les données de la piste au fichier MIDI
    trackData.insert(trackData.end(), trackHeader.begin(), trackHeader.end());
    unsigned long trackLength = 0;
    for (auto i = trackData.begin(); i != trackData.end(); ++i) {
        trackLength += *i;
    }
    header[11] = 0x01; // Nombre de pistes
    header[12] = trackLength >> 24;
    header[13] = (trackLength >> 16) & 0xFF;
    header[14] = (trackLength >> 8) & 0xFF;
    header[15] = trackLength & 0xFF;

    // Écrire les données du fichier MIDI dans un fichier
    std::ofstream outFile(filename, std::ios::out | std::ios::binary);
    outFile.write(reinterpret_cast<const char*>(&header[0]), header.size());
    outFile.write(reinterpret_cast<const char*>(&trackData[0]), trackData.size());
    outFile.close();

    // Fermer le port MIDI
    midiOut.closePort();

    return 0;
}
```
