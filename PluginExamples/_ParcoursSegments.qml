//==============================================
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//==============================================

import QtQuick 2.0
import QtQuick.Dialogs 1.1
import MuseScore 3.0

MuseScore {
      menuPath: "Dominique.ParcoursSegments"
      description: "Parcours des segments pour en connaitre le contenu"
      version: "1.0"

      
      // Quelques liens utiles
      // https://github.com/musescore/MuseScore/blob/master/libmscore/measurebase.h
      // https://github.com/musescore/MuseScore/blob/master/libmscore/measure.h


      // ======================   CONSTANTES =====================================

      property int cSCORE_START : 0;
      property int cSELECTION_START : 1;
      property int cSELECTION_END : 2;


      property int cNOM_COURT : 0;
      property int cNOM_LONG : 1;


      // ====================== FIN DES  CONSTANTES ================================




      //
      // -- Retourne la durée d'une note avec un nom plus ou moins long
      //
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


      onRun: {
          console.log("Lancement de parcours des segments")
          if (typeof curScore == 'undefined' || curScore == null) {
              console.log("Aucune partition active");
              Qt.quit();
          }


          var cursor = curScore.newCursor();
          cursor.track = 0;// on se positionne en début de partition
          cursor.rewind(cSCORE_START);

          // bornes des portées
          var premierePortee =  0;
          var dernierePortee = curScore.nstaves - 1;
          console.log("Première portée " + premierePortee);
          console.log("Dernière portée " + dernierePortee);

          var premierePiste = 0;
          var dernierePiste = ((dernierePortee + 1) * 4) -1;

          console.log("Première piste " + premierePiste);
          console.log("Dernière piste " + dernierePiste);


          
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
                          for (iNote = 0; iNote < notes.length; iNote++) {
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

                      case Element.REST :

                          accord = elt;
                          console.log(" ===== Piste : " + piste + " Silence : " + " durée : " + dureeAccord(accord,cNOM_LONG));
                          break;
                      default:
                          console.log(" ===== Piste : " + piste + " Elément de type imprévu ici :" + elt.name);
                      }

                  }
              }

              // on passe au segment suivant
              cursor.next();// rend vrai ou faux
              segment = cursor.segment;

          }


          console.log("Fin de parcours des segments");
            Qt.quit();
      }
}
