Bonjour, c'est Bing. Je peux vous aider à écrire un programme en QML pour MuseScore 3.0 pour exporter en MIDI la partition courante. Voici un exemple de code que j'ai généré en utilisant les informations des résultats de recherche¹²³:

```qml
import QtQuick 2.0
import MuseScore 3.0

MuseScore {
    menuPath: "Plugins.Exporter en MIDI"

    onRun: {
        // Récupérer la partition courante
        var score = curScore;

        // Vérifier si la partition existe
        if (score) {
            // Créer un nom de fichier à partir du titre de la partition
            var filename = score.title + ".mid";

            // Exporter la partition au format MIDI
            score.saveAs(filename, "midi");

            // Afficher un message de confirmation
            Qt.messageBox("Succès", "La partition a été exportée en MIDI sous le nom " + filename);
        }
        else {
            // Afficher un message d'erreur
            Qt.messageBox("Erreur", "Aucune partition ouverte.");
        }
    }
}
```

Ce code utilise l'API de MuseScore pour accéder à la partition courante, vérifier son existence, créer un nom de fichier et exporter la partition au format MIDI. Il utilise également l'API de Qt pour afficher des messages à l'utilisateur.

J'espère que cela vous a été utile. 😊

Source : conversation avec Bing, 09/03/2023(1) Ouvrir / Enregistrer / Exporter / Imprimer | MuseScore. https://musescore.org/fr/manuel/ouvrir-enregistrer-exporter-imprimer Consultée 09/03/2023.
(2) SoundFonts et fichiers SFZ | MuseScore. https://musescore.org/fr/manuel/soundfonts-et-fichiers-sfz Consultée 09/03/2023.
(3) Manuel de MuseScore 3 | MuseScore. https://musescore.org/fr/handbook Consultée 09/03/2023.


Envoyé depuis mon smartphone Samsung Galaxy.
