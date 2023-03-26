Bonjour, c'est Bing. Je peux vous aider à écrire un programme QML pour créer un plugin panel MuseScore 3.0 qui écoute un piano MIDI et à chaque note jouée, fait avancer le curseur de la partition en cours et colorie la note correspondante en fonction de la justesse de la note (note juste : vert, note en avance ou en retard : orange). La note est colorée sur la partition en cours. La partition courante est parcourue jusqu'à la fin de la sélection.

Voici un exemple possible de code QML qui utilise le plugin qmlmidi⁵ pour accéder aux périphériques MIDI et le type TextInput⁶ pour afficher les notes jouées :

```qml
import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import org.qmlmidi 1.0

MuseScore {
    menuPath: "Plugins.Piano MIDI"
    pluginType: "dock"
    width: 300
    height: 100

    MidiInput {
        id: midiInput
        onNoteOnReceived: {
            var note = MidiUtils.noteName(noteNumber) + octave;
            textInput.text = note;
            // TODO: move cursor and color note on score
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ComboBox {
            id: comboBox
            model: midiInput.devices()
            onCurrentIndexChanged: midiInput.openDevice(currentIndex)
        }

        TextInput {
            id: textInput
            readOnly: true
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
```

Source : conversation avec Bing, 09/03/2023(1) GitHub - jarnoh/qmlmidi: MIDI plugin for Qt Quick. Enables using MIDI .... https://github.com/jarnoh/qmlmidi Consultée 09/03/2023.
(2) TextInput QML Type | Qt Quick 6.4.2. https://doc.qt.io/qt-6/qml-qtquick-textinput.html Consultée 09/03/2023.
(3) Plugins for 3.x | MuseScore. https://musescore.org/en/handbook/developers-handbook/plugins-3x Consultée 09/03/2023.
(4) Boilerplates, snippets, use cases and QML notes | MuseScore. https://musescore.org/fr/node/320673 Consultée 09/03/2023.
(5) QML boilerplates | MuseScore. https://musescore.org/en/node/345720 Consultée 09/03/2023.
(6) Audio Overview | Qt Multimedia 6.4.2. https://doc.qt.io/qt-6/audiooverview.html Consultée 09/03/2023.


Envoyé depuis mon smartphone Samsung Galaxy.
