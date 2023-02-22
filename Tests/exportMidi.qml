// écrit par chatgpt

import QtQuick 2.0
import MuseScore 3.0

Panel {
    id: myPanel
    title: "Export MIDI"
    width: 200
    height: 100
    
    Button {
        id: exportButton
        text: "Export"
        anchors.centerIn: parent
        onClicked: {
            var score = MuseScore.score;
            if (score) {
                var selection = score.selection;
                var startElement = selection ? selection.firstElement : score.firstElement;
                var endElement = selection ? selection.lastElement : score.lastElement;
                var fileName = "export.mid";
                MuseScore.exportMidi(fileName, startElement, endElement);
            }
        }
    }
}
