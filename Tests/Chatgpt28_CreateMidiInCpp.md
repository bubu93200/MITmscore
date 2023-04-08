```cpp
#include <iostream>
#include <fstream>
#include <vector>
#include <chrono>
#include <thread>
#include "RtMidi.h"

struct MidiEvent
{
    int deltaTicks;
    std::vector<unsigned char> message;

    MidiEvent(int deltaTicks, const std::vector<unsigned char>& message)
        : deltaTicks(deltaTicks), message(message)
    {}
};

// Fonction pour convertir une durée en millisecondes en une quantité de ticks MIDI
int msToTicks(double ms, double bpm, int ppqn)
{
    double beats = ms / (60.0 / bpm * 1000.0);
    return static_cast<int>(beats * ppqn);
}

// Fonction pour générer les données de la piste MIDI à partir d'une séquence de notes
std::vector<unsigned char> generateMidiTrack(const std::vector<MidiEvent>& events, double bpm, int ppqn)
{
    std::vector<unsigned char> trackData;
    int deltaTicks = 0;

    // Ajouter l'événement de début de piste
    std::vector<unsigned char> trackHeader = { 0x00, 0xff, 0x58, 0x04, 0x04, 0x02, 0x18, 0x08 };
    trackData.insert(trackData.end(), trackHeader.begin(), trackHeader.end());

    // Ajouter les événements MIDI
    for (const auto& event : events)
    {
        deltaTicks += event.deltaTicks;

        // Ajouter le delta time
        while (deltaTicks > 0x7f)
        {
            trackData.push_back(0x80 | (deltaTicks & 0x7f));
            deltaTicks >>= 7;
        }
        trackData.push_back(deltaTicks);

        // Ajouter le message MIDI
        trackData.insert(trackData.end(), event.message.begin(), event.message.end());
    }

    // Ajouter l'événement de fin de piste
    std::vector<unsigned char> trackEnd = { 0x00, 0xff, 0x2f, 0x00 };
    trackData.insert(trackData.end(), trackEnd.begin(), trackEnd.end());

    // Ajouter l'en-tête de la piste
    std::vector<unsigned char> trackHeaderBytes = { 0x4d, 0x54, 0x72, 0x6b };
    int trackLength = trackData.size();
    trackHeaderBytes.push_back((trackLength >> 24) & 0xff);
    trackHeaderBytes.push_back((trackLength >> 16) & 0xff);
    trackHeaderBytes.push_back((trackLength >> 8) & 0xff);
    trackHeaderBytes.push_back(trackLength & 0xff);
    trackData.insert(trackData.begin(), trackHeaderBytes.begin(), trackHeaderBytes.end());

    return trackData;
}

int main()
{
    const std::string filename = "example.mid";
    const double bpm = 120
const int ppqn = 480;
const int channel = 0;
const int velocity = 64;

// Exemple de séquence de notes
std::vector<std::pair<int, int>> noteSequence = { {60, 1000}, {64, 500}, {67, 750} };

// Créer les événements MIDI à partir de la séquence de notes
std::vector<MidiEvent> events;
for (const auto& note : noteSequence)
{
    int noteOnTicks = msToTicks(0, bpm, ppqn);
    int noteOffTicks = msToTicks(note.second, bpm, ppqn);
    std::vector<unsigned char> noteOn = { 0x90 | channel, note.first, velocity };
    std::vector<unsigned char> noteOff = { 0x80 | channel, note.first, 0 };
    events.emplace_back(noteOnTicks, noteOn);
    events.emplace_back(noteOffTicks, noteOff);
}

// Générer les données de la piste MIDI
std::vector<unsigned char> trackData = generateMidiTrack(events, bpm, ppqn);

// Écrire les données de la piste MIDI dans le fichier
std::ofstream outputFile(filename, std::ios::binary);
if (outputFile.is_open())
{
    // Écrire l'en-tête du fichier MIDI
    std::vector<unsigned char> header = { 0x4d, 0x54, 0x68, 0x64, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x01, 0x00, static_cast<unsigned char>(channel + 1), static_cast<unsigned char>(ppqn >> 8), static_cast<unsigned char>(ppqn & 0xff) };
    outputFile.write(reinterpret_cast<const char*>(header.data()), header.size());

    // Écrire la piste MIDI
    outputFile.write(reinterpret_cast<const char*>(trackData.data()), trackData.size());

    outputFile.close();
}
else
{
    std::cout << "Erreur : impossible d'ouvrir le fichier " << filename << std::endl;
}

return 0;
```
