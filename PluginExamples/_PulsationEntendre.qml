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
//  Attention : la version de Musescore 3.6 (ou plus) est requise
//            : Soyez prudents si votre partition contient déjà une partie de WoodBlock
//  Copyright : 2022 Dominique Verrière
//==============================================

import QtQuick 2.0
import QtQuick.Controls 2.2
import MuseScore 3.0

MuseScore {
    menuPath: "Dominique.PulsationEntendre"
    description: "Entendre les pulsations pour les exporter au format MP3"
    version: "1.0"
    pluginType: "dialog"

    property bool debogage: false



    // -- Constantes
    
    property int cNOTE_PREMIER_TEMPS : 60;
    property int cNOTE_AUTRE_TEMPS : 61;

    // "#rrggbb" avec rr rouge de 0 à ff, gg vert de 0 à ff, bleu de 0 à ff
    property string cNoir : "#000000";
    property string cRouge : "#fe0000";
    property string cBlanc : "#ffffff";
    property string cBleuMusescore : "#2084b9";
    property string cVert : "#00ff00";

    property int cSCORE_START : 0;
    property int cSELECTION_START : 1;
    property int cSELECTION_END : 2;

    property string  cWOOD_BLOCK: "wood.wood-block"
    property int nVersionMajorMini : 3;
    property int nVersionMinorMini : 6;// à cause de certaines méthodes


    // -- Variables globales
    property bool preConditionsPassees : false
    property var curseur;    


    
    //
    // -- Vérifie que le programme va pouvoir tourner
    //
    function preConditions()
    {

        if (preConditionsPassees)
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
        
        preConditionsPassees = true;
        
        // notre variable globale
        curseur = curScore.newCursor();
        curScore.startCmd();        
        return true;
    }


    //
    // -- Obtenir la partie de WoodBlock si elle existe
    //
    function getPartieWoodBlock()
    {
        var partie;
        for (var iP = 0; iP < curScore.parts.length;iP++)
        {
            partie = curScore.parts[iP];
            if (partie.instrumentId === cWOOD_BLOCK )
                return partie;
            // Il est très peu probable qu'un musicien ajoute une partie masquée de WoodBlock
        }
        return null;
    }


    //
    // -- Crée une nouvelle partie de WoodBlock ou vide la partie si elle existe déjà
    //
    function creerPartieWoodBlock()
    {
        var partie;
        partie = getPartieWoodBlock();

        if (!partie)
        {// C'est une nouvelle partie de woodblock
            curScore.appendPartByMusicXmlId(cWOOD_BLOCK);
            partie = getPartieWoodBlock();
        }
        else
        {// C'est une partie existante de woodblock : on vide tout avant de commencer
            supprimerAnnotation("Avec pulsation",cRouge);
            supprimerNotesWoodBlock(partie);
        }
        // On modifie les propriétés de cette partie
        //partie.hasDrumStaff = true;       // plus writable en MuseScore 3.5 Snif !
        //partie.shortName = "Pulsation";   // plus writable en MuseScore 3.5 Snif !
        //partie.longName = "Pulsation";    // plus writable en MuseScore 3.5 Snif !
        partie.show = false;                // Depuis MuseScore 3.6

        ajouterAnnotation("Avec pulsation",cRouge);
        ajouterNotesWoodBlock(partie);
    }



    //
    // -- Suppression de la partie de pulsation (Nota : tout n'est pas possible à ce jour, il manque la méthode removePart();)
    //
    function supprimerPartieWoodBlock()
    {
        var partie;
        afficherTexte("Suppression de la partie de WoodBlock",cNoir);
        partie = getPartieWoodBlock();
        if (!partie)
        {
            afficherTexte("-- Pas de partie de WoodBlock à supprimer",cRouge);
            return;
        }
        else
        {
            supprimerAnnotation("Avec pulsation",cRouge);
            supprimerNotesWoodBlock(partie);
        }


        afficherTexte(" dans cette version de MuseScore, je ne peux supprimer une partie",cRouge);
        afficherTexte(" vous devez le faire manuellement en frappant I (comme Instruments)",cRouge);
        afficherTexte(" puis en supprimant la portée de WoodBlock",cRouge);
    }
    //
    // -- Ajoute une annotation pour savoir que l'on a une partie de WoodBlock
    //
    function ajouterAnnotation (message,cCouleur)
    {

        var crPortee1 = curScore.newCursor();
        crPortee1.track    = 0;  // on ajoute la notation sur la 1ère portée et la voix 1
        crPortee1.rewind(cSCORE_START);

        var elementTexte;

        elementTexte = newElement(Element.STAFF_TEXT);
        elementTexte.text = message;
        elementTexte.offsetX = 0;
        elementTexte.placement = Placement.ABOVE;
        elementTexte.color = cCouleur;

        crPortee1.add(elementTexte);
    }

    //
    // -- Supprime toute annotation de signalement de la portée 1
    //
    function supprimerAnnotation(message,cCouleur)
    {
        var annotation;
        var segment;
        var crPortee1 = curScore.newCursor();
        crPortee1.track    = 0;  // on retire la notation de la 1ère portée, voix 1
        crPortee1.rewind(cSCORE_START);

        while (crPortee1.segment)
        {
            segment = crPortee1.segment;
            if (segment.annotations.length)
            {
                for (var iA = 0; iA < segment.annotations.length;iA++)
                {
                    annotation = segment.annotations[iA];
                    if (annotation.type === Element.STAFF_TEXT &&
                            annotation.text === message )
                    {// On ne supprime que si c'est 'notre' message
                        removeElement(annotation);// ATTENTION Version 3.3 de Musescore requise !!!!
                    }
                }
            }
            crPortee1.next();
        }
    }


    //
    // -- On crée les notes du woodblock
    //
    function ajouterNotesWoodBlock(partie) {


        // Un curseur permet de décrire la portée de WoodBlock
        var crWoodBlock = curScore.newCursor();
        crWoodBlock.track = partie.startTrack;
        crWoodBlock.rewind(cSCORE_START);

        // Un curseur permet de décrire la portée 1 (pour trouver les mesures)
        var crPortee1 = curScore.newCursor();
        crPortee1.track    = 0;  // on parcourt la 1ère portée et la voix 1
        crPortee1.rewind(cSCORE_START);

        var tickPrec = -1;
        while (crPortee1.segment) {
            var mesure = crPortee1.measure;
            var tick = mesure.firstSegment.tick;
            if (mesure.firstSegment.tick !== tickPrec)
            {// On a changé de mesure...
                tickPrec = mesure.firstSegment.tick;
                // On récupère la signature de la mesure
                var numerateur = mesure.timesigActual.numerator;
                var denominateur = mesure.timesigActual.denominator;

                for (var pulse = 1; pulse <= numerateur; pulse++)
                {
                    crWoodBlock.setDuration(1, denominateur);
                    if (pulse === 1 )
                    {// Le 1er tick est différent des autres
                        crWoodBlock.addNote(cNOTE_PREMIER_TEMPS);
                    }
                    else
                    {
                        crWoodBlock.addNote(cNOTE_AUTRE_TEMPS);
                    }
                }
            }
            crPortee1.next();
        }
    }




    //
    // -- Vide les notes de la partie de WoodBlock (cas d'usage suppression, ajout de mesures, de chiffrage,..)
    //
    function supprimerNotesWoodBlock(partie)
    {
        var crWoodBlock;
        var element;

        
        crWoodBlock = curScore.newCursor();
        for (var piste = partie.startTrack; piste <= partie.endTrack; piste++) {
            crWoodBlock.track    = piste;
            crWoodBlock.rewind(cSCORE_START); // début de la partition
            while (crWoodBlock.segment ) {
                element = crWoodBlock.element;
                if (element) {
                    // Il y a un élément pour cette portée et cette voix
                    switch(element.type)
                    {
                    case Element.CHORD :
                        removeElement(element);
                        break;
                    default:
                        //afficherLog(" === Portée :  Elément de type imprévu ici :" + elt.name + " ??? ");
                        break;
                    }
                }
                crWoodBlock.next();// passe au segment suivant
            }
        }
    }





    // ================= Outils de débogage =================

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
        {// On affiche d'abord les propriétés
            if( typeof item[p1] != "function" )
                if(p1 !== "objectName" && (item[p1]))
                    afficherLog("Propriété " + p1 + ":" + item[p1]);
        }
        for (var p2 in item)
        {// Puis on affiche les fonctions
            if( typeof item[p2] == "function" )
                if(p2 !== "objectName" && (item[p2]))
                    afficherLog("Function " + p2 + ":" + item[p2]);
        }
    }


    // ============================ IHM ===================

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
                text: qsTr("Ajouter la partie de pulsation")

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
                        creerPartieWoodBlock();
                        if (!debogage)
                              {     
                               curScore.endCmd();
                               Qt.quit();
                              }
                    }

                }
            }





            Button {
                id: pbToutEnlever
                text: qsTr("Enlever la partie de pulsation")

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
                        supprimerPartieWoodBlock();
                        //curScore.endCmd();
                        // On ne quitte pas pour laisser afficher le message je ne peux pas...
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
