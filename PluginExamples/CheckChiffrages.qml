//==============================================
//
//  Ce programme est un logiciel libre: vous pouvez le redistribuer/modifier
//  sous les conditions de la licence GNU (Version 3 ou ultérieure)
//
//  Nous espérons que ce programme vous sera utile,
//  mais il est fourni SANS GARANTIE.   Voir la licence
//  GNU pour plus de détails.
//
//  Pour voir la licence GNU :
//  voir le site  <http://www.gnu.org/licenses/>.
//
//  Attention : la version de Musescore 4.0 (ou plus) est requise
//  Copyright : 2023 Dominique Verrière
//==============================================

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.15
import MuseScore 3.0

MuseScore {
    description: "Vérifie les chiffrages de chaque mesure.Signale en rouge les anomalies (Release " + cRelease + ")"
    title: "Check chiffrages"
    version: "4.0"
    pluginType: "dialog"
    thumbnailName: "CheckChiffrages.png"
    categoryCode: "Dominique"

    // -- Constantes
    property string cRelease : "4.003";
    // 4.003 White is not defined remplacé par cBlanc

    property bool debogage: false // Changer cette valeur à false pour passer en production

    // "#rrggbb" avec rr rouge de 0 à ff, gg vert de 0 à ff, bleu de 0 à ff
    property string cNoir : "#000000";
    property string cRouge : "#fe0000";
    property string cBlanc : "#ffffff";
    property string cBleuMusescore : "#2084b9";
    property string cVert : "#00ff00";

    property int cSCORE_START : 0;
    property int cSELECTION_START : 1;
    property int cSELECTION_END : 2;

    property int nVersionMajorMini : 4;
    property int nVersionMinorMini : 0;


    // -- Variables globales
    property var curseur;


    // -- Taille de la zone de dialogue

    function getWindowHeight() : real
    {
        if (debogage)
            {
            return 1000;
            }
        else
            {
            return 400;
            }
    }

    function getWindowWidth() : real
    {
        return getMenusWidth() + getLogWidth() + 10;
    }

    // -- Taille de la colonne log
    function getLogWidth() : real
    {
        return 500;
    }
    // -- Taille de la colonne menus
    function getMenusWidth() : real
    {
        return  350;
    }

    //
    // -- Ma gestion de logs personnalisée
    //
    function afficherLog(chaine, couleur)
    {
        if (debogage)
            lstMessages.append({"libelle":chaine, "couleur":couleur })
    }

    function viderLog()
    {
        if (debogage)
            lstMessages.clear();
    }

    function afficherTexte(texte,couleur)
    {
            lstMessages.append({"libelle":texte,"couleur":couleur })
    }

    //
    // -- Vérifie que le programme va pouvoir tourner, ouvre le curseur si OK
    //
    function preConditions()
    {

        if (curseur)
            return true;// a déjà été ouvert donc OK

        afficherTexte("Version de Musescore :" + mscoreMajorVersion + "." + mscoreMinorVersion,cNoir);

        if ( (mscoreMajorVersion < nVersionMajorMini) ||
            (mscoreMajorVersion == nVersionMajorMini && mscoreMinorVersion < nVersionMinorMini))
        {
            gererErreurBloquante("La version minimum de Musescore est " + mscoreMajorVersion + "." + nVersionMinorMini);
            return false;
        }


        if (typeof curScore == 'undefined' || curScore == null) {
            gererErreurBloquante("Il faut une partition");
            return false;
        }

        // notre variable globale
        curseur = curScore.newCursor();
        curScore.startCmd();
        return true;
    }


    function gererErreurBloquante(texteErreur)
    {
        txtAccueil.text = "Une erreur empêche le programme de tourner";
        txtAccueil.color = cRouge;
        txtResultat.text = texteErreur;
        txtResultat.color = cRouge;
        pbToutRemettre.visible = false;
        pbToutVerifier.visible = false;

    }

    //
    // -- Colorie une note,ses altérations,et ses points
    //
    function colorierNote(note,cCouleur) {

        // Coloration de la note proprement dite
        note.color = cCouleur;

        // Coloration des altérations de la note
        if (note.accidental) {
            note.accidental.color = cCouleur;
        }

        // Coloration des points associés à la note
        for (var iPoint = 0; iPoint < note.dots.length; iPoint++) {
            if (note.dots[iPoint]) {
                note.dots[iPoint].color = cCouleur;
            }
        }
    }


    //
    // -- Colorie un silence
    //
    function colorierSilence(accord,cCouleur) {

        // Coloration du silence proprement dit
        accord.color = cCouleur;

        // Voir si on peut obtenir les points

    }


    //
    // -- Générique de vidage des propriétés d'un élément
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
    // -- Fonction qui va colorier les notes si ecart de chiffrage et signalement
    //
    function parcourirNotes (curseur,bSignalement, cCouleurDefaut,cCouleurErreur)
    {
        var segment;
        var elt;

        var mesure;
        var notes;
        var note;
        var iNote;

        var accords;
        var accord;
        var iAccord;

        var cCouleur;

        curseur.rewind(cSCORE_START);

        // bornes des portées
        var premierePortee =  0;
        var dernierePortee = curScore.nstaves - 1;


        afficherLog("= Parcours des segments des portées : " + premierePortee + "-" + dernierePortee)

        for (var portee = premierePortee; portee <= dernierePortee; portee++) {
            for (var voix = 0; voix <= 3; voix++) {
                curseur.voice    = voix;
                curseur.staffIdx = portee;
                curseur.rewind(cSCORE_START); // début de la partition
                while (curseur.segment ) {
                    segment = curseur.segment;
                    afficherLog(" == " + segment.name  + " de type : " + segment.type + " au tick : " + segment.tick + " sur la portée : " + portee+ " et la voix : "+ voix);

                    mesure = curseur.measure;
                    cCouleur = cCouleurDefaut;
                    if (mesure.timesigNominal.str !== mesure.timesigActual.str)
                    {
                        if (bSignalement)
                        {
                            cCouleur = cCouleurErreur;
                        }
                    }


                    elt = curseur.element;
                    if (elt) {
                        // Il y a un élément pour cette portée et cette voix
                        switch(elt.type)
                        {
                        case Element.CHORD :
                            notes = elt.notes; // notes de cet accord (toute note appartient à un accord)
                            for (iNote = 0; iNote < notes.length; iNote++) {
                                note = notes[iNote];
                                colorierNote(note,cCouleur);
                            }


                            accords = elt.graceNotes; // appogiatures
                            for (iAccord = 0; iAccord < accords.length; iAccord++) {
                                notes = accords[iAccord].notes;// notes de l'accord
                                for (iNote = 0; iNote < notes.length; iNote++)
                                {
                                    note = notes[iNote];
                                    colorierNote(note,cCouleur);
                                }
                            }


                            break;

                        case Element.REST :

                            accord = elt;
                            colorierSilence(accord,cCouleur);
                            break;
                        default:
                            afficherLog(" === Portee : " + portee + " Voix : " + voix +" Elément de type imprévu ici :" + elt.name + " ??? ");
                            break;
                        }
                    }
                    curseur.next();// passe au segment suivant
                }
            }
        }
    }

    //
    // -- Parcours des mesures pour signalement/désignalement
    //
    function parcourirMesures (curseur,bSignalement,cCouleurDefaut,cCouleurErreur)
    {
        var segment;
        var mesure;
        var tickPrec = -1;

        var nbSegments = 0;
        var nbMesures = 0;
        var nbEcarts = 0;

        curseur.rewind(cSCORE_START);


        afficherTexte("= Parcours des mesures" ,cNoir)

        curseur.voice    = 0;
        curseur.staffIdx = 0;
        curseur.rewind(cSCORE_START); // début de la partition
        while (curseur.segment ) {
            segment = curseur.segment;
            afficherLog(" == " + segment.name  + " de type : " + segment.type + " au tick : " + segment.tick);
            supprimerAnnotations(curseur,segment,cCouleurErreur);// ménage préalable
            nbSegments++;

            mesure = curseur.measure;
            if (mesure.firstSegment.tick !== tickPrec)
            {
                nbMesures++;
                tickPrec = mesure.firstSegment.tick;
                afficherLog(" == mesure " + mesure.timesigActual.str + " au tick " + mesure.firstSegment.tick);
                if (mesure.timesigActual.str !== mesure.timesigNominal.str)
                {// En cas d'écart seulement
                    nbEcarts++;
                    // uniquement en mode signalement
                    if (bSignalement)
                    {
                        var message = "Mesure " + mesure.timesigActual.str + " au lieu de " + mesure.timesigNominal.str
                        ajouterAnnotation(curseur,mesure.firstSegment.tick,message,cCouleurErreur);
                    }
                }
            }
            curseur.next();// passe au segment suivant
        }


        afficherTexte("== " + nbSegments + " segments et "+ nbMesures +" mesures ont été trouvées",cNoir)
        txtResultat.text =  nbMesures + " mesures";
        txtResultat.color = cVert;
        if (nbEcarts > 0)
        {
            txtResultat.text += " dont " + nbEcarts + " avec écart de chiffrage"
            txtResultat.color = cRouge;
        }

    }


    //
    // -- Ajoute du texte au dessus du 1er accord de chaque mesure
    //
    function ajouterAnnotation (curseur,tick,message,cCouleur)
    {
        var txt;

        txt = newElement(Element.STAFF_TEXT);
        txt.text = message;
        txt.offsetX = 0;
        txt.placement = Placement.ABOVE;
        txt.color = cCouleur;

        curseur.add(txt);
        afficherLog("== Ajout du STAFF_TEXT " + message + " au tick : " + tick )
    }


    //
    // -- Supprime les annotations précédentes pour permettre N lancements
    //
    function supprimerAnnotations(curseur,segment,cCouleur)
    {
        var element;

        afficherLog ("supprimerAnnotations de la couleur " + cCouleur);
        if (segment.annotations.length)
        {
            afficherLog ("supprimerAnnotations avec annotation au tick " + segment.tick,cNoir);
            for (var iA = 0; iA < segment.annotations.length;iA++)
            {
                element = segment.annotations[iA];
                // afficherProprietes(element);
                if (element.type === Element.STAFF_TEXT)
                {
                    afficherLog("-- Un STAFF_TEXT au tick " + segment.tick + " avec une couleur " + element.color + " versus " + cCouleur)
                    if (element.color == cCouleur)
                    {//  ?? un cast empêche la comparaison  avec === ??
                        removeElement(element);
                        afficherLog("-- Suppression du STAFF_TEXT au tick " + segment.tick)
                    }
                }

            }

        }
    }




    //
    // -- Création de la fenêtre de dialogue
    //
    id:window
    width:  getWindowWidth()
    height: getWindowHeight()

    onRun: {}


Rectangle {
    color: cBlanc
    anchors.fill: parent


    Column {
        spacing:10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalTop

        Row {
            spacing: 10
            Column  {// Marge gauche
                       width: 10
                       height: getWindowHeight()
                   }
            Column {// Menus et textes d'accueil
                spacing: 10
                anchors.horizontalCenter: parent.horizontalLeft
                anchors.verticalCenter: parent.verticalTop
                width: getMenusWidth()

                Row{// Texte d'accueil
                    Text {
                        id: txtAccueil
                        text: "Faites votre choix de vérification de chiffrage :"
                    }
                }
                Row{// Boutons
                    Column{// Boutons
                        spacing: 10
                        Button {
                            id: pbToutVerifier
                            text: qsTr("Tout vérifier")
                            contentItem: Text {
                                text: pbToutVerifier.text
                                font: pbToutVerifier.font
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
                                viderLog();
                                if (preConditions())
                                {
                                    parcourirNotes(curseur,true,cNoir,cRouge);
                                    parcourirMesures(curseur,true,cNoir,cRouge);
                                }

                            }
                        }
                        Button {
                            id: pbToutRemettre
                            text: qsTr("Tout remettre en noir")

                            contentItem: Text {
                                text: pbToutRemettre.text
                                font: pbToutRemettre.font
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
                                viderLog();
                                if (preConditions())
                                {
                                    parcourirNotes(curseur,false,cNoir,cRouge);
                                    parcourirMesures(curseur,false,cNoir,cRouge);
                                    curScore.endCmd();
                                }
                                if (!debogage)
                                {
                                    quit();
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
                                quit();
                            }
                        }
                    }

                }
                Row{// Texte de résultats
                    Text {
                        id:txtResultat
                        text: " "
                        color: cNoir
                    }
                }
                Row{// Lien Youtube
                    Column{
                       spacing: 10
                       Text {
                           id:txtRelease
                           text: "Plugin AfficherPulsation release " + cRelease
                           color: cNoir
                       }

                       Text {
                           id:txtYoutube
                           text: "Autres plugins sur https://www.youtube.com/@DominiqueVerriere "
                           color: cNoir
                       }
                    }
                }
            }

            Column{// L'affichage du log
                spacing:10
                anchors.horizontalCenter: parent.horizontalRight
                anchors.verticalCenter: parent.verticalTop
                width: getLogWidth()
                height: getWindowHeight()
                Text {
                    id: txtCompteRedu
                    text: "Compte rendu d'exécution"
                }
                Rectangle{
                    width:getLogWidth();height:getWindowHeight(); color:cBlanc

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
                        // Pas de scrollbar dans cette version
                    }
                }

            }
        }
    }
}
}

