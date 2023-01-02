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

MuseScore { // Démarrage d'un plgin Musescore
    property string pluginsPath: "C:/Users/Bubu/Documents/MuseScore3/Plugins"
    property string midiPath: "C:/Users/Bubu/Documents/MuseScore3/Partitions"
    property string defaultInstrument: "Your instrument"

    menuPath:   "Plugins.MidiInstrumentTraining"
    version:  "1.0"
    description: "This plugin do tests on Musescore features"

    pluginType: "dialog"
    width: 200
    height: 600
            
    
    
    onRun: {
        console.info("*********** DEBUT *********"); // Message d'information
        proc1.start(pluginsPath+"/MIT/qsynthconnect.sh "+instrumentName.text);
        // console.info("*********** FIN *********"); // Message d'information
    }
     
    
    Column { //mise en colonne des éléments
        spacing: 0 //units.gu(2) espacement entre items
        anchors.centerIn: parent

        Text { // Affichage d'un texte
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Debugging/nCopyright (c) Bruno Donati/n"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Affichage de vavirables"
        }
        
        TextField { // Zone d'insertion d'un texte avec éventuellement un texte par défaut (input)
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