# Target
The aim of this github is to write a plugin for Musecore 3 and 4.  
This plugin have to help person for learning or training piano.  
So we have to play a score and plugin shows mistakes in playing and can analyse playing meaning.   


# Original Plugin running on Musescore 2.0 with linux 
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


Install GNU Library to have posix libraries.

# API Musescore 
Handbook : https://musescore.org/en/handbook/developers-handbook  
Doc API 3.0 : https://musescore.org/en/handbook/developers-handbook/plugins-3x   
API 3.5 Documentation Doxygen : https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/index.html   
Doc API 4.0 : https://musescore.org/en/node/337468   
Structure des partitions: https://musescore.org/en/handbook/developers-handbook/plugins-3x#API_inheritance_versus_Score_Structure   
Structure des partitions: https://musescore.org/en/developers-handbook/references/musescore-internal-score-representation


# Progress 
All is to do   
At this moment, I just collected libraries which can be used on this project 
  - inital MIT working with score 2.0 and GNU linux
  - GNU  
  - alsa : Advanced Linux Sound Architecture (ALSA) project  
  - Score 3.6.2 and process to compile it in debug mode with visual studio (doesnt work with visual code)  
  - Jack  
  
- [ ] TODO : Transpose to windows  
- [ ] TODO : All  

# Way to progress   
Musescore are written in Qt so I propose to write musescore interface in Qt.  
Qt can send programs so I propose to write launched programs in python  
Avantages to use python:  
- code simplier   
- a lot of libraries (and usable MIDI libraries) : mido      
- python works on windows, linux, MacOS so program in python is usable on these 3 systems without modifications  
- C or C++ code can be embedded in python script if necessary to accelerate code execution   

# Program architecture 
This program can be use for all midi instrument be I will test it on a piano. 
The "instrument" term is used for piano or keyboard  

## Plugin Panel
I explain here fonctionnalities / buttons / checkboxes / text / entries to add on panel   
It's organized in 3 tabs : training, setting and help. 

### training tab  
- Title : "MIT" meaning Musescore Instrument Training   
- button "Start" => start training. Waiting for playing midi instrument  

### Setting tab   
- checkbox : metronome or not  
- entry : number => number of mesures with metronome before score playing  
### Help tab  
 
## Setting File    
- file is read at each launch. 
- If not exist, create a setting file with default options   
- at each end of program, overwrite this setting file with current settings  
## On musescore sheet : (written in Qt)  
  - create L and R symbols (and other if necessary) which ca nbe attached on each note   
  - colorize in purple or cyan notes attached to L or R symbols (colors can be modified)  
## Qt sheet or panel to interface to program (written in Qt)   
  - button to select pourcentage of velocity (to play slowly for training)  
  - checkbox to select Left and/or Right fingering to play
  - input "Midi instrument name"  
  - input "Midi instrument channel"  
  - button to begin training    
  - weigthing for colorize: evaluate note played   

## On button "begin training" (written in python) 
  - create midi file of the score (perhaps it can be created before)  
  - create a Midi input to hear Midi instrument. 
  - on each note in midi file :
    - read midi file of instrument input
    - make a comparison between reference Midi file and input from instrument.  
    - on scoresheet colorize note from green to red to evaluate if note is played good or false  
    - on scoresheet advance cursor to next note  

# Build Qt5.15.2 with visual studio 2019  
See this link : https://gist.github.com/rsouth/f029ce1bd093dc573afa8f48846e471c  
Use commands :    
````
cd C:\Qt\qt-5.15.0-src
mkdir ..\qt-5.15.0-static
set QTDIR=C:\Qt\qt-5.15.0-src\qtbase
set PATH=C:\Qt\qt-5.15.0-src\qtbase\bin;%PATH%
configure -debug-and-release -prefix "C:\Qt\qt-5.15.0-static" -opensource -platform win32-msvc -opengl desktop -static -static-runtime -nomake examples -nomake tests
nmake
nmake install
````
Be careful, **nmake** works without end. Go to **nmake install** when you see it loops several time   
Be careful to have **python** installed  
It seems to be possible to build with Visual studio 2022   

# To build Qt5.15.2 with Visual Studio 2022
Qt5.15.2 use at latest release Visual Studio 2019 (msvc2019_64)   
If you want to use Visual Studio 2022 with Qt 5.15.2, you have to buils Qt for Visual Studio 2022  
Go to Visual Studio 2022 and open a terminal (Tools -> Command Line -> Command prompt / Outils -> Ligne de commande -> Invite de commande développer)
On invite de commande go to Qt 5.15.2 sources directory (C:\Qt\5.15.2\Src)  
Write commands :
```
configure -prefix C:\Qt\5.15.2\msvc2022_64 -platform win32-msvc2022 -opensource -confirm-license  
nmake  
nmake install  
```   
Qt 5.15.2 and building is done on C:\Qt\5.15.2\msvc2022_64   
Don't work. Fatal error due to incompatibility


# Releases  
0.00 Nothing at this point. Testing releases  
