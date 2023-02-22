// écrit par ChatGPT

import QtQuick 2.0
import MuseScore 3.0

Pane {
    id: myPane
    title: "My Plugin"

    property var currentScore: null
    property var currentPart: null

    // Fonction pour créer un fichier MIDI à partir de la partition courante ou des notes sélectionnées
    function createMidiFile() {
        var notesToExport = []
        var scoreToExport = currentScore

        // Si des notes sont sélectionnées, ne garder que celles-ci
        if (currentPart.selection.length > 0) {
            notesToExport = currentPart.selection
            scoreToExport = currentPart
        }

        // Créer le fichier MIDI
        var exportPath = "/path/to/your/export/folder/"
        var exportFilename = "export.mid"
        var exportFile = exportPath + exportFilename
        scoreToExport.exportMidi(exportFile, notesToExport)
    }

    // Fonction pour comparer les notes jouées aux notes de la partition
    function compareNotesPlayedToScore(notesPlayed) {
        for (var i = 0; i < currentPart.notes.length; i++) {
            var currentNote = currentPart.notes[i]
            var currentNoteStartTime = currentNote.msPos
            var currentNoteEndTime = currentNoteStartTime + currentNote.duration

            // Vérifier si la note est en train d'être jouée
            for (var j = 0; j < notesPlayed.length; j++) {
                var currentPlayedNote = notesPlayed[j]
                var currentPlayedNoteTime = currentPlayedNote.startTime

                // Si la note est jouée pendant la durée de la note de la partition
                if (currentPlayedNoteTime >= currentNoteStartTime && currentPlayedNoteTime <= currentNoteEndTime) {
                    // Vérifier si la note est juste, en avance ou en retard
                    var difference = Math.abs(currentPlayedNote.pitch - currentNote.pitch)
                    if (difference == 0) {
                        // Note juste
                        currentNote.color = "green"
                    } else if (difference <= 2) {
                        // Note légèrement en avance ou en retard
                        currentNote.color = "orange"
                    } else {
                        // Note incorrecte
                        currentNote.color = "red"
                    }
                }
            }
        }
    }

    // Bouton de démarrage
    Button {
        text: "Démarrer"
        onClicked: {
            // Créer le fichier MIDI
            createMidiFile()

            // Écouter les notes jouées au piano MIDI
            MidiInput.start()
            MidiInput.notePlayed.connect(function(notesPlayed) {
                // Comparer les notes jouées aux notes de la partition et colorier les notes en conséquence
                compareNotesPlayedToScore(notesPlayed)
            })
        }
    }

    // Gestionnaire d'événements pour la sélection de partition
    onCurrentScoreChanged: {
        if (currentScore == null) {
            return
        }

        var parts = currentScore.parts
        if (parts.length > 0) {
            currentPart = parts[0]
        }
    }
}
