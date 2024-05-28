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
    version: "1.0"
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

        if (curseur)
            return true;// a déjà été ouvert donc OK

        preConditionsPassees = false;       

        if ( (mscoreMajorVersion < nVersionMajorMini) ||
            (mscoreMajorVersion == nVersionMajorMini && mscoreMinorVersion < nVersionMinorMini))
        {
            afficherTexte("La version minimum de Musescore est " + nVersionMajorMini + "." + nVersionMinorMini,cRouge);
            return false;
        }
        else
        {
        afficherTexte("Version de Musescore : " + mscoreMajorVersion + "." + mscoreMinorVersion + " OK",cNoir);
        }

        if (typeof curScore == 'undefined' || curScore == null) {
            afficherTexte("Il faut une partition",cRouge);
            return false;
        }
        
        // notre variable globale
        curseur = curScore.newCursor();
        
        if (!controlerNotesVoix4(curseur)){
            afficherTexte("La voix 4 est utilisée",cRouge);
            return false;
        }
        else
        {
         afficherTexte("La voix 4 est libre OK",cNoir);
        }
                
        curScore.startCmd();
        preConditionsPassees = true;
        return true;
    }





    //
    // -- On vérifie que la voix 4 n'est pas utilisée sur la portée 1
    //
    function controlerNotesVoix4 (curseur)
    {
        var segment;
        var elt;
        var iNbeAccords = 0;
        var bRetour = true;
        var message = "";

        curseur.rewind(cSCORE_START);

        // Portées à contrôler
        var premierePortee =  0;
        var dernierePortee = 0;// dans cette première version seule la portée 1
        //var dernierePortee = curScore.nstaves - 1;


        for (var portee = premierePortee; portee <= dernierePortee; portee++) {
            iNbeAccords = 0;
            curseur.voice    = cVOIX4;// on ne contrôle que la voix 4
            curseur.staffIdx = portee;
            curseur.rewind(cSCORE_START); // début de la partition
            while (curseur.segment ) {
                segment = curseur.segment;
                elt = curseur.element;
                if (elt) {
                    // Il y a un élément pour cette portée et cette voix
                    switch(elt.type)
                    {
                    case Element.CHORD :
                        iNbeAccords++;
                        break;
                    default:
                        //afficherLog(" === Portee : " + portee + " Voix : " + voix +" Elément de type imprévu ici :" + elt.name + " ??? ");
                        break;
                    }
                }
                curseur.next();// passe au segment suivant
            }
            if (iNbeAccords > 0)
            {
                bRetour = false; // car la précondition échoue
                message = "Ce plugin utilise la voix 4 qui doit être libre ";
                message += " (" + iNbeAccords + " accords/notes en portée " + portee + 1 + ")";
                afficherTexte(message ,cRouge);
            }
        }
        return bRetour;
    }


    //
    // -- On ajoute les silences sur la voix 4
    //
    function ajouterSilences(curseur) {

        curseur.staffIdx = 0;// sur la 1ère portée
        curseur.voice    = cVOIX1;// on parcourt la voix 1
        curseur.rewind(cSCORE_START);
        var tickPrec = -1;

        while (curseur.segment) {
            var mesure = curseur.measure;
            var tick = mesure.firstSegment.tick;
            if (mesure.firstSegment.tick !== tickPrec)
            {// a-t-on changé de mesure ?
                tickPrec = mesure.firstSegment.tick;
                afficherLog("Mesure en " + tick);
                // On récupère la signature de la mesure
                var numerateur = mesure.timesigActual.numerator;
                var denominateur = mesure.timesigActual.denominator;
                curseur.voice = cVOIX4; // la voix 4 (supposée libre)
                for (var pulse = 1; pulse <= numerateur - 1; pulse++)
                {// en fait il y a déjà un silence , d'où le numerateur - 1
                    curseur.setDuration(1, denominateur);
                    curseur.addRest(); // Attention il FAUT la 3.5
                }
            }
            curseur.voice = cVOIX1; // retour à la voix 1
            curseur.next();
        }
    }


    //
    // -- Parcourir les silences de la voix 4 ,ajoute la pulsation et supprime le silence
    //
    function ajouterPulsations (curseur)
    {
        var segment;
        var element;

        curseur.rewind(cSCORE_START);

        // Portées à traiter
        var premierePortee =  0;
        var dernierePortee = 0;// dans cette première version seule la portée 1
        //var dernierePortee = curScore.nstaves - 1;


        for (var portee = premierePortee; portee <= dernierePortee; portee++) {
            curseur.voice    = cVOIX4;// on parcourt la voix 4
            curseur.staffIdx = portee;
            curseur.rewind(cSCORE_START); // début de la partition
            while (curseur.segment ) {
                segment = curseur.segment;
                element = curseur.element;
                if (element) {
                    // Il y a un élément pour cette portée et cette voix
                    switch(element.type)
                    {
                    case Element.CHORD :
                        break;
                    case Element.REST :
                        curseur.voice = cVOIX1; // on ajoute la pulsation sur la voix 1
                        ajouterPulsation(curseur,cNoir);
                        curseur.voice = cVOIX4; // retour à la voix 4
                        removeElement(element);// ATTENTION Version 3.3 de Musescore requise !!!!
                        break;
                    default:
                        //afficherLog(" === Portee : " + portee + " Voix : " + voix +" Elément de type imprévu ici :" + element.name + " ??? ");
                        break;
                    }
                }
                curseur.next();// passe au segment suivant
            }
        }
    }


    //
    // -- Ajoute une pulsation en dessous
    //
    function ajouterPulsation (curseur,cCouleur)
    {
        var unePulse;

        unePulse = newElement(Element.STAFF_TEXT);
        unePulse.text = "|";
        unePulse.offsetX = 0.5;
        unePulse.offsetY = 4;
        unePulse.placement = Placement.BELOW;
        unePulse.color = cCouleur;
        curseur.add(unePulse);
    }


    //
    // -- Suppression des pulsations de toute la partition (METHODE spéciale car STAFF_TEXT non accessible autrement)
    //
    function supprimerPulsations(curseur)
    {
        var segment;
        var element;
        afficherLog("ParcoursDesSegments de la portée");
        segment = curScore.firstSegment();
        if (!segment)
        {
            afficherLog("-- firstSegment de la partition est NULL");
            return;
        }

        var nbeSuppressions = 0;
        while (segment)
        {
            if (segment.annotations)
            {
                for (var iA = 0; iA < segment.annotations.length;iA++)
                {
                    element = segment.annotations[iA];
                    if (element.type === Element.STAFF_TEXT)
                    {
                        afficherLog("Elément de type STAFF_TEXT :" + element.text );
                        if (element.text === "|")
                        {
                            removeElement(element);// ATTENTION Version 3.3 de Musescore requise !!!!
                            nbeSuppressions++;
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
    width:  600
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
                        supprimerPulsations(curseur);
                        ajouterSilences(curseur);
                        ajouterPulsations(curseur);
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
                        supprimerPulsations(curseur);
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
                width:550;height:370; color:white

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
