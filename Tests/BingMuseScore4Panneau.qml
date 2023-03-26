MuseScore 4.0 est la dernière version du logiciel de notation musicale gratuit et open source. Elle apporte de nombreuses améliorations et nouveautés, notamment au niveau de l'interface utilisateur qui est basée sur QML². QML est un langage déclaratif qui permet de créer des interfaces dynamiques et modernes avec une syntaxe proche du JavaScript¹.

Pour écrire le même programme que pour MuseScore 3.0, il faut adapter le code QML en tenant compte des changements dans l'API des plugins et des éléments graphiques. Voici un exemple possible de code QML qui crée un plugin MuseScore 4.0 avec un panneau contenant un titre, 3 boutons et des zones d'input de texte :

```qml
import MuseScore 4.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

MuseScore {
    menuPath: "Plugins.Mon plugin"
    pluginType: "dock"
    width: 300
    height: 200

    ColumnLayout {
        anchors.fill: parent

        Text {
            id: title
            text: "Mon plugin"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            Button {
                id: button1
                text: "Bouton 1"
                onClicked: console.log("Bouton 1 cliqué")
            }

            Button {
                id: button2
                text: "Bouton 2"
                onClicked: console.log("Bouton 2 cliqué")
            }

            Button {
                id: button3
                text: "Bouton 3"
                onClicked: console.log("Bouton 3 cliqué")
            }
        }

        RowLayout {
            Text {
                id: label1
                text: "Texte 1 : "
            }

            TextField { // changed from TextInput to TextField for better appearance and functionality 
                id: input1
                placeholderText: "Entrez du texte ici"
            }
        }

        RowLayout {
            Text {
                id: label2
                text: "Texte 2 : "
            }

            TextField { // changed from TextInput to TextField for better appearance and functionality 
                id: input2
                placeholderText: "Entrez du texte ici"
            }
        }
    }
}
```

Source : conversation avec Bing, 09/03/2023(1) Update on MuseScore 3.6 and 4.0 | MuseScore. https://musescore.org/en/node/312563 Consultée 09/03/2023.
(2) 【MuseScore杂谈】4. 带您走近MuseScore开发 - 哔哩哔哩. https://www.bilibili.com/read/cv10177910/ Consultée 09/03/2023.
(3) QML boilerplates | MuseScore. https://musescore.org/en/node/345720 Consultée 09/03/2023.
(4) MuseScore 4 est sorti. https://formation-musescore-af-media.fr/musescore-4-de-grands-changements-positifs/ Consultée 09/03/2023.


Envoyé depuis mon smartphone Samsung Galaxy.
