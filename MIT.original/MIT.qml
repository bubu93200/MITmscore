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

import QtQuick 2.2
//import QtQuick.Controls 2.0
import QtQuick.Controls 1.1 // avant il s'agissait de la version 2.0. Vérifier que cela fonctionne toujours.
import QtQuick.Controls.Styles 1.3 // Pour ?
import QtQuick.Layouts 1.1 // Pour ?
import QtQuick.Dialogs 1.1 // Pour ?
import MuseScore 3.0


MuseScore {
    property string pluginsPath: "C:/Users/Bubu/Documents/MuseScore3/Plugins"
    property string midiPath: "C:/Users/Bubu/Documents/MuseScore3/Partitions"
    property string defaultInstrument: "Your instrument"

    menuPath:   "Plugins.MidiInstrumentTraining"
    version:  "1.0"
    description: "This plugin takes input from a MIDI instrument and colors notes while you play from blue (note and rhythm are perfect) to red (bad note or bad rhythm)."

    pluginType: "dialog"
    width: 200
    height: 550

    /* console.warn("warn completed")
            console.log("log completed")
            console.error("error completed")
            console.debug("debug completed")
            console.exception("exception completed") */
            
    
    
    onRun: {
        console.info("*********** DEBUT *********"); // Message d'information
        proc1.start(pluginsPath+"/MIT/qsynthconnect.sh "+instrumentName.text);
        // console.info("*********** FIN *********"); // Message d'information
    }
    
    QProcess { id: proc1 }
    QProcess { id: proc2 }  
    
    Column {
        spacing: 0 //units.gu(2) espacement entre items
        anchors.centerIn: parent
        
        Button {
            id: start
            anchors.horizontalCenter: parent.horizontalCenter
            text: "START"
            
            //style: ButtonStyle {} Quelle librairie ?
            
            onClicked: {
                console.info("Click start Button"); // Message d'information
                console.info(curScore.scoreName); // Message d'information
                applyToNotesInSelection(uncolorNote);
                
                console.info(pluginsPath+"/MIT/MIT "+instrumentName.text
                +" "+midiPath+"/"+curScore.scoreName+".mid "
                +instrumentChannel.text+" "+scoreChannel.text+" "
                +max_badness.text+" "+weight_start.text+" "
                +weight_endp.text+" "+weight_endn.text);
                
                proc2.start(pluginsPath+"/MIT/MIT "+instrumentName.text
                +" "+midiPath+"/"+curScore.scoreName+".mid "
                +instrumentChannel.text+" "+scoreChannel.text+" "
                +max_badness.text+" "+weight_start.text+" "
                +weight_endp.text+" "+weight_endn.text);
            }
        }
        
        
        Button {
            id: stop
            anchors.horizontalCenter: parent.horizontalCenter
            text: "STOP"
            onClicked: {
                console.info("Click stop Button"); // Message d'information
                console.info(pluginsPath+"/MIT/stopMIT");
                proc2.kill();
                proc2.waitForFinished(-1);
                proc2.start(pluginsPath+"/MIT/stopMIT");
            }
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Score channel:"
        }
        
        TextField {
            id: scoreChannel
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40
            text: "0"
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "MIDI Instrument name:"
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
        
        Button {
            id: synth
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ReStart Synth"
            onClicked: {
                proc1.kill();
                proc1.waitForFinished(-1);
                proc1.start(pluginsPath+"/MIT/qsynthconnect.sh "+instrumentName.text);
            }
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
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "WEIGHT END (-):"
        }
        TextField {
            id: weight_endn
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40
            text: "5"
        }
        
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "MAX BADNESS:"
        }
        
        TextField {
            id: max_badness
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40
            text: "100"
        }
        
       
    }
            

    property string black : "#000000"

 
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
                            func(note);
                        }
                    }
                    cursor.next();
                }
            }
        }
    }
 
  
    function uncolorNote(note) {
        note.color = black;
    }
        
}
    

    

    


