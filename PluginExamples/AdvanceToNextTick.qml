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
// Copyright (C) 2024 Bruno Donati
//=============================================================================

// Quelques liens utiles  TODO : mettre à jour les liens
// https://github.com/musescore/MuseScore/blob/master/libmscore/measurebase.h
// https://github.com/musescore/MuseScore/blob/master/libmscore/measure.h
    
import QtQuick 2.0
//import QtQuick.Dialogs 1.1
import QtQuick.Controls 2.0
import MuseScore 3.0

    

MuseScore {
    menuPath: "Plugins.AdvanceToNextTick"
    description: "This plugin do tests on Musescore features"
    version:  "1.0"
    pluginType: "dialog" //TODO : Mettre dock pour avoir un menu ancré
    
    width:  300
    height: 800

    // ====================== DEBUT MENU ========================================
    Column {
        //mise en colonne des éléments
        spacing: 0 //units.gu(2) espacement entre items
        anchors.centerIn: parent

        Text { // Affichage d'un texte
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Debugging\nCopyright (c) Bruno Donati\n"
        }
        
        Button { // Affichage d'un bouton
            anchors.horizontalCenter: parent.horizontalCenter
            id: start
            
            text: "Start"
            background: Rectangle {
                    id: startrectangle
                    property bool isBlue : true
                    implicitWidth: 100
                    implicitHeight: 40
                    //color: isBlue ? "#d6d6d6" : "#f6f6f6"
                    color: isBlue ? "blue" : "red"
                    border.color: "#26282a"
                    border.width: 1
                    radius: 4
                }

            //style: ButtonStyle {} Quelle librairie ?

            onPressedChanged: {
                    startrectangle.isBlue = !(startrectangle.isBlue);
                }

            onClicked: {
                    console.info("Click start Button"); // Message d'information
                    console.info(curScore.scoreName); // Message d'information
                    runlecture();
                }
            
        }
    }
    // ====================== FIN MENU ==========================================
    

    // ======================  DEBUT CONSTANTES =====================================

    property int cSCORE_START : 0;
    property int cSELECTION_START : 1;
    property int cSELECTION_END : 2;

    property int cNOM_COURT : 0;
    property int cNOM_LONG : 1;


    // ====================== FIN CONSTANTES ===============================



    // ====================== DEBUT Fonctions ===================================
    //
      // -- Retourne un nom en clair à partir de son pitch
      //
      function nomNote(note)
      {
          var nomNote;
          switch (note.tpc) {
             case -1: nomNote =  "FA/F♭♭" ; break;
             case  0: nomNote =  "DO/C♭♭" ; break;
             case  1: nomNote =  "SOL/G♭♭" ; break;
             case  2: nomNote =  "RE/D♭♭" ; break;
             case  3: nomNote =  "LA/A♭♭" ; break;
             case  4: nomNote =  "MI/E♭♭" ; break;
             case  5: nomNote =  "SI/B♭♭" ; break;
             
             case  6: nomNote =  "FA/F♭"  ; break;
             case  7: nomNote =  "DO/C♭"  ; break;
             case  8: nomNote =  "SOL/G♭"  ; break;
             case  9: nomNote =  "RE/D♭"  ; break;
             case 10: nomNote =  "LA/A♭"  ; break;
             case 11: nomNote =  "MI/E♭"  ; break;
             case 12: nomNote =  "SI/B♭"  ; break;

             case 13: nomNote =  "FA/F"   ; break;
             case 14: nomNote =  "DO/C"   ; break;
             case 15: nomNote =  "SOL/G"   ; break;
             case 16: nomNote =  "RE/D"   ; break;
             case 17: nomNote =  "LA/A"   ; break;
             case 18: nomNote =  "MI/E"   ; break;
             case 19: nomNote =  "SI/B"   ; break;

             case 20: nomNote =  "FA/F♯"  ; break;
             case 21: nomNote =  "DO/C♯"  ; break;
             case 22: nomNote =  "SOL/G♯"  ; break;
             case 23: nomNote =  "RE/D♯"  ; break;
             case 24: nomNote =  "LA/A♯"  ; break;
             case 25: nomNote =  "MI/E♯"  ; break;
             case 26: nomNote =  "SI/B♯"  ; break;

             case 27: nomNote =  "FA/F♯♯" ; break;
             case 28: nomNote =  "DO/C♯♯" ; break;
             case 29: nomNote =  "SOL/G♯♯" ; break;
             case 30: nomNote =  "RE/D♯♯" ; break;
             case 31: nomNote =  "LA/A♯♯" ; break;
             case 32: nomNote =  "MI/E♯♯" ; break;
             case 33: nomNote =  "SI/B♯♯" ; break;
             default: nomNote = "Cas imprévu " + note.tpc   ; break;
          }
          return nomNote;
      }
    
    function dureeNote(note,typeDuree)
    {
        var accord = note.parent; // toute note fait partie d'un accord
        var retour = "";
        retour = dureeAccord(accord,typeDuree);
        return retour;
    }

          //
      // -- Retourne la durée d'un accord avec un nom plus ou moins long
      //
      function dureeAccord(accord,typeDuree)
      {
          var duree = accord.duration.str;
          var retour = duree;
          if (typeDuree == cNOM_LONG)
          {
              retour = retour + " " + nomDuree(duree);
          }

          return retour;
      }

      //
      // -- Retourne le nom de la durée en clair  
      //
      function nomDuree(duree)
      {
          var retour = "??" + duree + "??";
          switch (duree)
          {
          case "4/4" : retour = "mesure";break
          case "1/1" : retour = "ronde";break
          case "1/2" : retour = "blanche";break
          case "1/4" : retour = "noire";break
          case "1/8" : retour = "croche";break
          case "1/16" : retour = "double croche";break
          case "1/32" : retour = "triple croche";break
          case "1/64" : retour = "quadruple croche";break
          default: retour = "Cas imprévu " + duree       ; break;
          }

          return retour;
      }

    // Fonction principale du plugin

    function runlecture()
    {
        var cursor = curScore.newCursor();
        
        cursor.rewind(0);


        cursor.track = 0;// on se positionne en début de partition

        // bornes des portées
        var premierePortee =  0;
        var dernierePortee = curScore.nstaves - 1;
        console.log("Première portée " + premierePortee);
        console.log("Dernière portée " + dernierePortee);

        var premierePiste = 0;
        var dernierePiste = ((dernierePortee + 1) * 4) -1;

        console.log("Première piste " + premierePiste);
        console.log("Dernière piste " + dernierePiste);


        // Trouve le tick actuel
        var currentTick = cursor.tick;
        console.info("Numero du tick : ",currentTick);
        cursor.next();
        currentTick = cursor.tick;
        console.info("Numero du tick : ",currentTick);

        // variables de travail
          var elt;
          var accord;
          var mesure;
          var note;
          var notes;
          var alerte;
          var iNote;

         // Le segment courant de cette portée
          var segment = cursor.segment;
          while (segment) {
              // Pour chaque segment
              console.log(" == Segment de type " + segment.name + " au tick : " + segment.tick);

              mesure = cursor.measure;
              alerte = "";
              if (mesure.timesigNominal.str != mesure.timesigActual.str)
                {alerte = " !!! DIFFERE DE METRIQUE !!!";}
              console.log(" === Mesure durée nominale : " + mesure.timesigNominal.str + " actuelle " + mesure.timesigActual.str + alerte);
              
              for (var piste = premierePiste; piste <= dernierePiste; piste++) {
                  // console.log(" === Piste : " + piste)
                  elt = segment.elementAt(piste);
                  if (elt) {
                      // Il y a un élément pour cette piste
                      
                      switch(elt.type)
                      {
                      case Element.CHORD :
                          notes = elt.notes;
                          console.log(" ==== Notes");
                          for (var iNote = 0; iNote < notes.length; iNote++) {
                              note = notes[iNote];
                              console.log(" ===== Piste : " + piste + " Note : " + nomNote(note) + " durée : " + dureeNote(note, cNOM_LONG))
                          }


                          var graceChords = elt.graceNotes;
                          for (var iAccord = 0; iAccord < graceChords.length; iAccord++) {
                              var graceNotes = graceChords[iAccord].notes;
                              for (iNote = 0; iNote < graceNotes.length; iNote++)
                              {
                                  note = graceNotes[iNote];
                                  console.log(" ===== Piste : " + piste + " Gracenote : " + nomNote(note) + " durée : " + dureeNote(note,cNOM_LONG))
                              }
                          }


                          break;

                      /*
                      case Element.REST :

                          accord = elt;
                          console.log(" ===== Piste : " + piste + " Silence : " + " durée : " + dureeAccord(accord,cNOM_LONG));
                          break;
                      default:
                          console.log(" ===== Piste : " + piste + " Elément de type imprévu ici :" + elt.name);
                      */
                      }
                      
                  }
              }

              // on passe au segment suivant
              cursor.next();// rend vrai ou faux
              segment = cursor.segment;

          }

        /*
        // Trouve le prochain tick avec une note
        var nextTick = currentTick;
        var found = false;
        while (cursor.next() && !found) {
            if (cursor.tick > currentTick) {
                nextTick = cursor.tick;
                console.log("Next Tick: ",nextTick);
                found = true;
                if (cursor.element.type === Element.NOTE) {
                    console.log("Type: ");
                    console.log("Note: ",cursor.element.note);
                    console.log("Duree: ",dureeNote(cursor.element,cNO));
                    console.log("Color: ",cursor.element.color);
                    cursor.element.color = "red";
                }
            }
        }

        if (found) {
            cursor.rewind(nextTick);

            // Colorie toutes les notes au tick trouvé en rouge
            do {
                if (cursor.element.type == Element.NOTE) {
                    cursor.element.color = "red";
                }
            } while (cursor.next() && cursor.tick == nextTick);
        }
        */
    }
   
    // ====================== FIN Fonctions ===================================

  

    onRun: {
       console.log("Lancement de la lecture de partition")
       if (typeof curScore == 'undefined' || curScore == null) {
           console.log("Aucune partition active");
           Qt.quit();
       }
    }
    
}
