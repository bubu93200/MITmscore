//=============================================================================
//  Midi Instrument Training plugin for MuseScore
//  Copyright (C) 2014 Jean-Baptiste Delisle
//  Based on colornotes plugin :
//  Copyright (C) 2012 Werner Schweer
//  Copyright (C) 2013 Nicolas Froment, Joachim Schmitz
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================
// Mise à jour pour MuseScore 3
// Copyright (C) 2022 Bruno Donati
//=============================================================================

// Fichiers de tests pour voir comment accéder à MuseScore

import QtQuick 2.2
//import QtQuick.Controls 2.0
import QtQuick.Controls 1.1 // avant il s'agissait de la version 2.0. Vérifier que cela fonctionne toujours.
import QtQuick.Controls.Styles 1.3 // Pour ?
import QtQuick.Layouts 1.1 // Pour ?
import QtQuick.Dialogs 1.1 // Pour ?
import MuseScore 3.0
import FileIO 3.0

MuseScore { // Démarrage d'un plgin Musescore
    property string pluginsPath: "C:/Users/Bubu/Documents/MuseScore3/Plugins"
    property string midiPath: "C:/Users/Bubu/Documents/MuseScore3/Partitions"
    property string defaultInstrument: "Your instrument"
    property string green   : "#008000"
    property string orange  : "#FFA500"
    property string red     : "#FF0000"
    property string blue    : "#0000FF"
    property string cyan    : "#00FFFF"
    property string magenta : "#FF00FF"

    menuPath:   "Plugins.MidiInstrumentTraining"
    version:  "0.05"
    description: "Midi Instrument training - Test release - This plugin do tests on Musescore features"
    requiresScore: false

    //pluginType: "dialog"
    pluginType: "dock" //panel 
    dockArea:   "left"
    width: 300
    height: 800


    Timer {
			interval: 1000;
			running:  false; //true; pour démarrer
			repeat:   true;
			onTriggered: {
                                    console.info(curScore.scoreName);
				                    console.info(curScore.path);
                                    //thisScore=curScore;
                                    //isCurScore=true;
                                    // DEBUG META INFO
                                    //console.log("--title: "+thisScore.title);
                                    console.info("--title: "+curScore.title);
                                    console.info("--lyricist: "+curScore.lyricist);
                                    console.info("--composer: "+curScore.composer);
                                    console.info("--arranger: "+curScore.metaTag("arranger"));
                                    console.info("--workNumber: "+curScore.metaTag("workNumber"));
                                    console.info("--movementNumber: "+curScore.metaTag("movementNumber"));
                                    console.info("--movementTitle: "+curScore.metaTag("movementTitle"));
                                    console.info("--creation year: "+Qt.formatDate(new Date(curScore.metaTag("creationDate")),"yyyy"));
                
                                 /*
                                 if (oldScore != curScore) {
					console.log("oldScore: " + oldScore);
					console.log("curScore: " + curScore);
					oldScore = curScore;
                                 }
				       */
			}    
    }
    
    FileIO { // lecture ou écriture d'un fichier
        id: exampleFile
        source: "/tmp/example.txt"
        // cette api est définie par les fichiers C++ suivants : 
        // mscore/plugin/api/util.h
        // mscore/plugin/api/util.cpp

    }
    onRun: {
        var test = exampleFile.read();
        console.log(test); // will print the file content
        console.info("*********** DEBUT *********"); // Message d'information
        //proc1.start(pluginsPath+"/MIT/qsynthconnect.sh "+instrumentName.text);
        // console.info("*********** FIN *********"); // Message d'information
        var cursor = curScore.newCursor();
        
    }
     
    
    Column { //mise en colonne des éléments
        spacing: 0 //units.gu(2) espacement entre items
        anchors.centerIn: parent

        Text { // Affichage d'un texte
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Debugging\nCopyright © Bruno Donati\n"
        }
        
        // META INFO
        Text { // Affichage d'un texte
            anchors.horizontalCenter: parent.horizontalCenter
            text: "--title: "+curScore.title+"\n--lyricist: "+curScore.lyricist+"\n--composer: "+curScore.composer+"\n";                          
        }
        
        Text { // Affichage d'un texte
            anchors.horizontalCenter: parent.horizontalCenter
            text: "--arranger: "+curScore.metaTag("arranger")+"\n--workNumber: "+curScore.metaTag("workNumber")+"\n--movementNumber: "+curScore.metaTag("movementNumber")+"\n";                          
        }
        
        Text { // Affichage d'un texte
            anchors.horizontalCenter: parent.horizontalCenter
            text: "--movementTitle: "+curScore.metaTag("movementTitle")+"\n--creation year: "+Qt.formatDate(new Date(curScore.metaTag("creationDate")),"yyyy")+"\n";                          
        }
                
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Affichage de la piste: "; // + cursor.track(1); ne fonctionne pas
        }

        //***********************************
        // Colorer les notes sélectionnées
        // Fonctionne mais il faut revenir sur la partition pour voir la modification
        //***********************************
        Button { // Affichage d'un bouton
            id: start
            anchors.horizontalCenter: parent.horizontalCenter
            text: "START all selected green" // Colore la selection
            
            //style: ButtonStyle {} Quelle librairie ?
            
            onClicked: {
                console.info("Click START all selected green Button"); // Message d'information
                console.info(curScore.scoreName); // Message d'information
                applyToNotesInSelection(colorNote);
            }
        }

        Button { // Affichage d'un bouton
            id: start2
            anchors.horizontalCenter: parent.horizontalCenter
            text: "START first note orange" // Colore la selection
            
            //style: ButtonStyle {} Quelle librairie ?
            
            onClicked: {
                console.info("Click START first note orange Button"); // Message d'information
                console.info(curScore.scoreName); // Message d'information

                // colorie la première note en orange ---> ne marche pas
                var cursor = curScore.newCursor();
                cursor.rewind(0);
                var notes = cursor.element.notes;               
                var note = notes[0];
                note.color = orange;
                cursor.next();
                  
                
            }
        }
        
        Button { // Affichage d'un bouton
            id: start3
            anchors.horizontalCenter: parent.horizontalCenter
            text: "START hear instrument" // Colore la selection
            
            //style: ButtonStyle {} Quelle librairie ?
            
            onClicked: {
                console.info("Click START hear instrument"); // Message d'information
                

                // init object MuseScore
                // var museScore =  MuseScore.curScore; FONCTIONNE
                var museScore = MuseScore;

                // initialize Midi Input
                if (museScore !== null) {
                    midiInput = museScore.midiSignal.createInput("MIDI input")

                    if (midiInput !== null) {
                        midiInput.onMessageReceived.connect(handleMidiEvent)
                        console.log("MIDI input opened: " + midiInput.name)
                    }
                }
                
                // Abonnement aux signaux MIDI entrants
                museScore.midiSignal.connect(onMidiSignalReceived)
                  
            }
        }

        TextField { // Zone d'insertion d'un texte avec éventuellement un texte par défaut (input)
            id: scoreChannel
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40
            text: "0"
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "MIDI Instrument name:" + text.arg(curScore.nstaves);
        }
        
        TextField {
            id: instrumentName
            anchors.horizontalCenter: parent.horizontalCenter
            width: 150
            text: defaultInstrument
        } 
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "MIDI Instrument channel:"
        }
        
        TextField {
            id: instrumentChannel
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40
            text: "0"
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "WEIGHT START:"
        }
        TextField {
            id: weight_start
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40
            text: "10"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "WEIGHT END (+):"
        }
        TextField {
            id: weight_endp
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40
            text: "10"
        }
    }   

function applyToNotesInSelection(func) {
        var cursor = curScore.newCursor();
        cursor.rewind(1);
        var startStaff  = cursor.staffIdx;
        cursor.rewind(2);
        var endStaff   = cursor.staffIdx;
        var endTick    = cursor.tick // if no selection, end of score
        var fullScore = false;
        if (!cursor.segment) { // no selection
            fullScore = true;
            startStaff = 0; // start with 1st staff
            endStaff = curScore.nstaves - 1; // and end with last
        }
        console.log(startStaff + " - " + endStaff + " - " + endTick)
        for (var staff = startStaff; staff <= endStaff; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                cursor.rewind(1); // sets voice to 0
                cursor.voice = voice; //voice has to be set after goTo
                cursor.staffIdx = staff;

                if (fullScore)
                cursor.rewind(0) // if no selection, beginning of score

                while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                    if (cursor.element && cursor.element.type == Element.CHORD) {
                        var notes = cursor.element.notes;
                        for (var i = 0; i < notes.length; i++) {
                            var note = notes[i];
                            note.color=green;
                            //func(note);
                        }
                    }
                    cursor.next();
                }
            }
        }
    }

    // Colore la note courante selon la couleur :
    // "red", "green", "blue", "orange", "yellow", "purple", "pink", "gray", "black" ou un code hexadexcimal
    function highlightNoteWithColor(note, color) {
        var cursor = MuseScore.curScore.cursor;
        cursor.reset();
        cursor.tick = note.tick;
        cursor.rewind(1);
        cursor.next();
        cursor.color = color;
    }
    // exemple d'appel à la fonction pour la première note de la partition courante
    // var score = MuseScore.curScore;
    // var part = score.parts[0];
    // var noteList = part.notes;
    // var noteToHighlight = noteList[0]; // on choisit la première note de la partition pour l'exemple
    //highlightIncorrectNoteWithColor(noteToHighlight, "orange");

    function colorNote(note) {
        note.color = green;
    }

    // Fonction appelée lorsqu'un signal MIDI est reçu
    function onMidiSignalReceived(signal) {
        // Traitement du signal MIDI
        // Vérification que la note jouée correspond à la note de la partition courante
        var currentNote = museScore.currentNote()
        if (currentNote && signal.note == currentNote.pitch()) {
            // La note jouée est correcte
            // Mettre en surbrillance la note dans la partition
            currentNote.highlight(true)
            // Afficher un commentaire sur la performance de l'utilisateur
            performanceFeedback.text = "Note correcte"
        } else {
            // La note jouée est incorrecte
            // Afficher un commentaire sur la performance de l'utilisateur
            performanceFeedback.text = "Note incorrecte"
        }
    }



}
