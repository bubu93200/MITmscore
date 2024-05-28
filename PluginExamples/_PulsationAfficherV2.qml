//==============================================
//
//  Ce programme est un logiciel libre: vous pouvez le redistribuer/modifier
//  sous les conditions de la licence GNU (Version 3 ou ultérieure)
//
//  Nous espèrons que ce programme vous sera utile,
//  mais il est fourni SANS GARANTIE.   Voir la licence
//  GNU pour plus de détails.
//
//  Pour voir la licence GNU :
//  voir le site  <http://www.gnu.org/licenses/>.
//
//  Attention : la version de Musescore 3.5 (ou plus) est requise
//  Copyright : 2022 Dominique Verrière
//==============================================

import QtQuick 2.0
import QtQuick.Controls 2.2
import MuseScore 3.0

MuseScore {
    menuPath: "Dominique.PulsationAfficher"
    description: "Affiche les pulsations sous les notes en utilisant la voix 4"
    version: "2.0"
    pluginType: "dialog"

    property bool debogage: false



    // -- Constantes

    // "#rrggbb" avec rr rouge de 0 à ff, gg vert de 0 à ff, bleu de 0 à ff
    property string cNoir : "#000000";
    property string cRouge : "#fe0000";
    property string cBlanc : "#ffffff";
    property string cBleuMusescore : "#2084b9";
    property string cVert : "#00ff00";

    property int cSCORE_START : 0;
    property int cSELECTION_START : 1;
    property int cSELECTION_END : 2;

    property int cVOIX1: 0
    property int cVOIX4: 3
    property int nVersionMajorMini : 3;
    property int nVersionMinorMini : 5;// à cause de certaines méthodes


    // -- Variables globales
    property var curseur;
    property bool preConditionsPassees : false
    property int premierePortee; // de 0 à N - 1
    property int dernierePortee; // de 0 à N - 1
    property int premierTick;
    property int dernierTick;

    
    //
    // -- Affichage dans la fenêtre de log en débogage
    //
    function afficherLog(texte)
    {
        if (debogage)
            lstMessages.append({"libelle":texte, "couleur":cNoir })
    }
    
    function afficherTexte(texte,couleur)
    {
            lstMessages.append({"libelle":texte,"couleur":couleur })
    }



    //
    // -- Générique de vidage (débogage) des propriétés d'un élément
    //
    function afficherProprietes(item)
    {
        afficherLog("===> Elément nom :" + item.name + " de type:" + item.type);
        for (var p1 in item)
        {
            if( typeof item[p1] != "function" )
                if(p1 !== "objectName" && (item[p1]))
                    afficherLog("Propriété " + p1 + ":" + item[p1]);
        }
        for (var p2 in item)
        {
            if( typeof item[p2] == "function" )
                if(p2 !== "objectName" && (item[p2]))
                    afficherLog("Function " + p2 + ":" + item[p2]);
        }
    }
    
    
    //
    // -- Vérifie que le programme va pouvoir tourner, ouvre le curseur si OK
    //
    function preConditions()
    {

        if (preConditionsPassees)
            return true;// a déjà été ouvert donc OK

        preConditionsPassees = false;

        if (!verifierPartition())
            return false;

        if (!verifierVersionMuseScore())
            return false;

        if (!verifierSelection())
            return false;
        
        
        if (!verifierVoix4Libre())
            return false;

        // notre variable globale évite la fermeture de la boite de dialogue (sauf si endCmd)
        curseur = curScore.newCursor();
        curScore.startCmd();
        preConditionsPassees = true;
        return true;
    }


    //
    // -- Vérifier la présence d'une partition
    //
    function verifierPartition()
    {
        if (typeof curScore == 'undefined' || curScore == null)
        {
            afficherTexte("Il faut une partition",cRouge);
            return false;
        }
        else
            return true;
    }

    //
    // -- Vérifier la version de MuseScore
    //
    function verifierVersionMuseScore()
    {
        if ( (mscoreMajorVersion < nVersionMajorMini) ||
                (mscoreMajorVersion == nVersionMajorMini && mscoreMinorVersion < nVersionMinorMini))
        {
            afficherTexte("La version minimum de Musescore est " + nVersionMajorMini + "." + nVersionMinorMini,cRouge);
            return false;
        }
        else
        {
            afficherTexte("Version de Musescore : " + mscoreMajorVersion + "." + mscoreMinorVersion ,cNoir);
            afficherTexte("Version du plugin    : " + version ,cNoir);

            return true;
        }
    }

    //
    // -- Vérifier la présence d'une sélection
    //
    function verifierSelection()
    {
        // afficherLog("verifierSelection");
        var selection = curScore.selection;
        premierePortee = selection.startStaff;
        dernierePortee = selection.endStaff - 1;
        if (!selection || dernierePortee < premierePortee)
        {
            if (curScore.nstaves > 1)
            {
                afficherTexte("Avec plusieurs portées, il faut en sélectionner une",cRouge);
                return false;
            }
            else
            {
                premierePortee = 0;
                dernierePortee = 0;
                premierTick = curScore.firstMeasure.firstSegment.tick;
                dernierTick = curScore.lastMeasure.lastSegment.tick;
                afficherTexte("Aucune sélection faite, s'appliquera à la partition ( ticks " + premierTick + " : " + dernierTick +" )",cNoir);
                return true;
            }
        }
        else
        {
            premierTick = selection.startSegment.tick;
            if (selection.endSegment)
                  dernierTick = selection.endSegment.tick - 1;
            else
                  dernierTick = curScore.lastMeasure.lastSegment.tick;
            afficherTexte ("Une sélection a été faite de la portée " + (premierePortee + 1) + " à la portée " + (dernierePortee + 1) +" ( ticks " + premierTick + " : " + dernierTick +" )",cNoir);
             return true;
        }

    }

    //
    // -- On vérifie que la voix 4 n'est pas utilisée sur les portée sélectionnées
    //
    function verifierVoix4Libre ()
    {
        afficherLog("=== verifierVoix4Libre");
        var elt;
        var nbeAccords = 0;
        var bRetour = true;
        var message = "";
        var mesure;
        var crLecture = curScore.newCursor();
        for (var portee = premierePortee; portee <= dernierePortee; portee++)
        {
            crLecture.voice    = cVOIX4;  // on ne contrôle que la voix 4
            crLecture.staffIdx = portee;
            crLecture.rewind(cSCORE_START); // début de la partition

            while (crLecture.segment ) {
                afficherLog ("Segment en track : " + crLecture.track + " voice : " + crLecture.voice + " tick : " + crLecture.tick);
                if (crLecture.tick > dernierTick)
                    break;// Après notre sélection
                if (crLecture.tick >= premierTick)
                {// dans notre sélection
                    mesure = crLecture.measure;
                    elt = crLecture.element;
                    if (elt) {
                        // Il y a un élément pour cette portée et cette voix
                        switch(elt.type)
                        {
                        case Element.CHORD :
                            nbeAccords++;
                            break;
                        default:
                            //afficherLog(" === Portee : " + portee + " Voix : " + voix +" Elément de type imprévu ici :" + elt.name + " ??? ");
                            break;
                        }
                    }
                }
                crLecture.next();// passe au segment suivant
            }
        }

        if (nbeAccords > 0)
        {
            bRetour = false; // car la précondition échoue
            message = "Ce plugin utilise la voix 4 qui doit être libre ";
            message += " (" + nbeAccords + " accords/notes trouvés sur les portées (" + (premierePortee + 1) + " : "+ (dernierePortee + 1) + ")";
            afficherTexte(message ,cRouge);
        }
        else
            afficherTexte("La voix 4 est libre",cNoir);

        return bRetour;
    }


    //
    // -- On ajoute les silences sur la voix 4
    //
    function ajouterSilences()
    {
        // afficherLog("=== ajouterSilences premierePortee " + premierePortee + " dernierePortee "+ dernierePortee);

        var crEcriture = curScore.newCursor();
        var tickPrec;
        var mesure;
        var numerateur;
        var denominateur;

        for (var portee = premierePortee;portee <= dernierePortee;portee++)
        {
            crEcriture.staffIdx = portee   ;   // sur une portée de la sélection
            crEcriture.voice    = cVOIX1;      // on parcourt la voix 1
            crEcriture.rewind(cSCORE_START);
            tickPrec = -1;
            while (crEcriture.segment) {
                // afficherLog ("Segment en track : " + curseur.track + " voice : " + curseur.voice + " tick : " + curseur.tick);
                if (crEcriture.tick > dernierTick)
                    break;// Après notre sélection
                if (crEcriture.tick >= premierTick)
                {// dans notre sélection
                    mesure = crEcriture.measure;
                    if (mesure.firstSegment.tick !== tickPrec)
                    {// On a changé de mesure
                        tickPrec = mesure.firstSegment.tick;
                        // On récupère la signature de la mesure
                        numerateur = mesure.timesigActual.numerator;
                        denominateur = mesure.timesigActual.denominator;
                        crEcriture.voice = cVOIX4; // la voix 4 (supposée libre)
                        for (var pulse = 1; pulse <= numerateur - 1; pulse++)
                        {// en fait il y a déjà un silence , d'où le numerateur - 1
                            crEcriture.setDuration(1, denominateur);
                            crEcriture.addRest(); // Attention il FAUT la 3.5
                        }
                    }
                }
                crEcriture.voice = cVOIX1; // retour à la voix 1
                crEcriture.next();
            }
        }

    }


    //
    // -- Parcourir les silences de la voix 4 ,ajoute la pulsation et supprime le silence
    //
    function ajouterPulsations ()
    {
        var element;

        var crEcriture = curScore.newCursor();

        for (var portee = premierePortee; portee <= dernierePortee; portee++) {
            crEcriture.voice    = cVOIX4;      // on parcourt la voix 4
            crEcriture.staffIdx = portee;      // on parcourt la portée sélectionnée
            crEcriture.rewind(cSCORE_START);   // début de la partition
            while (crEcriture.segment )
            {
                if (crEcriture.tick > dernierTick)
                    break;// Après notre sélection
                if (crEcriture.tick >= premierTick)
                {// Dans notre sélection
                    element = crEcriture.element;
                    if (element) {
                        // Il y a un élément pour cette portée et cette voix
                        switch(element.type)
                        {
                        case Element.REST :
                            crEcriture.voice = cVOIX1; // on ajoute la pulsation sur la voix 1
                            ajouterPulsation(crEcriture,cNoir);
                            crEcriture.voice = cVOIX4; // retour à la voix 4
                            removeElement(element);// ATTENTION Version 3.3 de Musescore requise !!!!
                            break;
                        default:
                            break;
                        }
                    }
                }
                crEcriture.next();// passe au segment suivant
            }
        }
    }


    //
    // -- Ajoute une pulsation en dessous de la portée
    //
    function ajouterPulsation (crEcriture,cCouleur)
    {
        var unePulse;

        unePulse = newElement(Element.STAFF_TEXT);
        unePulse.text = "|";
        unePulse.offsetX = 0.5;
        unePulse.offsetY = 4;
        unePulse.placement = Placement.BELOW;
        unePulse.color = cCouleur;
        crEcriture.add(unePulse);
    }


    //
    // -- Suppression des pulsations de toute la partition (METHODE spéciale car STAFF_TEXT non accessible autrement)
    //
    function supprimerPulsations()
    {
        var segment;
        var element;
        var portee;
        afficherLog("Parcours des segments sélectionnés de la partition");
        segment = curScore.firstSegment();
        if (!segment)
        {
            afficherLog("-- firstSegment de la partition est NULL");
            return;
        }

        var nbeSuppressions = 0;
        while (segment)
        {
            if (segment.tick >= premierTick && segment.tick <= dernierTick)
            {// Dans notre sélection
                if (segment.annotations)
                {
                    for (var iA = 0; iA < segment.annotations.length;iA++)
                    {
                        element = segment.annotations[iA];
                        portee = element.track / 4;
                        if (element.type === Element.STAFF_TEXT && portee >= premierePortee && portee <= dernierePortee)
                        {
                            afficherLog("Elément de type STAFF_TEXT :" + element.text + " en portée " + portee + " voix "  + element.voice);
                            if (element.text === "|")
                            {
                                removeElement(element);// ATTENTION Version 3.3 de Musescore requise !!!!
                                nbeSuppressions++;
                            }
                        }
                    }
                }
            }

            segment = segment.next;
        }
        afficherTexte(nbeSuppressions + " pulsations ont été supprimées",cNoir);
    }


    //
    // -- Création de la fenêtre de dialogue
    //
    id:window
    width:  800
    height: 600

    onRun: 
    {
          if (!preConditions())
          {
           pbToutAjouter.button_enabled = false;
           pbToutEnlever.button_enabled = false;
          }
    }

    Rectangle {
        color: cBlanc
        anchors.fill: parent


        Text {
            id: txtAccueil
            text: " Faites votre choix pour générer les pulsations : "
        }
        Column {

            spacing:10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter


            Button {
                id: pbToutAjouter
                text: qsTr("Ajouter toutes les pulsations")

                contentItem: Text {
                    text: pbToutAjouter.text
                    font: pbToutAjouter.font
                    opacity:  1.0
                    color: cBlanc
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: cBleuMusescore
                    implicitWidth: 150
                    implicitHeight: 40
                    opacity: 1.0
                    border.color: cNoir
                    border.width: 2
                    radius: 2
                }
                onClicked:
                {
                    if (preConditions())
                    {
                        supprimerPulsations();
                        ajouterSilences();
                        ajouterPulsations();
                        curScore.endCmd();
                        if (!debogage)
                            Qt.quit();
                    }

                }
            }
            Button {
                id: pbToutEnlever
                text: qsTr("Enlever toutes les pulsations")

                contentItem: Text {
                    text: pbToutEnlever.text
                    font: pbToutEnlever.font
                    opacity:  1.0
                    color: cBlanc
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: cBleuMusescore
                    implicitWidth: 150
                    implicitHeight: 40
                    opacity: 1.0
                    border.color: cNoir
                    border.width: 2
                    radius: 2
                }
                onClicked:
                {
                    if (preConditions())
                    {
                        supprimerPulsations();
                        curScore.endCmd();
                        if (!debogage)
                            Qt.quit();
                    }
                }

            }
            Button {
                id: pbQuitter
                text: qsTr("Quitter")

                contentItem: Text {
                    text: pbQuitter.text
                    font: pbQuitter.font
                    opacity:  1.0
                    color: cBlanc
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: cBleuMusescore
                    implicitWidth: 150
                    implicitHeight: 40
                    opacity: 1.0
                    border.color: cNoir
                    border.width: 2
                    radius: 2
                }
                onClicked:
                {
                    curScore.endCmd();
                    Qt.quit();
                }
            }

            Text {
                id:txtResultat
                text: " "
                color: cNoir
            }

            // L'affichage du log
            Rectangle{
                width:650;height:370; color:white

                ListModel
                {
                    id: lstMessages
                }
                Component
                {
                    id: clMessage
                    Text {
                        text: model.libelle;
                        color:model.couleur;
                    }
                }

                ListView {
                    id:lbLog
                    anchors.fill:parent
                    model:lstMessages
                    delegate:clMessage
                    clip:true
                }
            }
        }
    }

}
