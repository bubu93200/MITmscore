# MIDI
Explications sur le protocole MIDI :  
https://www.linuxrouen.fr/wp/programmation/introduction-a-la-programmation-midi-avec-python-mido-et-rtmidi-23805/  

#MidiMate Ex  
Le cable USB/MIDI Midimate Ex nécessite l'installation d'un driver ES_Midiport. Le driver est dans le répertoire MidiMate

Librairies Midi :  
- RtMidi => implémentation légère
- PortMidi => Documentation illisible
- JUCE => Libraire très lourde. Non trouvée sur github. libre ?


#RtMidi  
J'ai choisi d'utiliser RtMidi

## Configuration
Compliqué:  
- il faut ajouter #define __WINDOWS_MM__ dans RtMidi.h pour indiquer que la compilation se fait sur windows
- apparemment, il faut ajouter dans Visual Studio : propriétés /Editeur de liens / entrée / dépendances supplémentaires un lien vers WinMM.lib (pas sur que ce soit nécessaire)  

