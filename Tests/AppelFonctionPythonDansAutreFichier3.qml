// programme exemple 5
# song.py
def getSongInfo(filename):
    # Implémenter la fonction Python pour obtenir les informations de la chanson en utilisant le paramètre filename
    return ("Title", "Artist", "Album")

# main.qml
import sys
import QtQuick 2.0
import QtQuick.Controls 1.4
import song

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Song Info")

    Button {
        id: infoButton
        anchors.centerIn: parent
        text: qsTr("Get Song Info")
        onClicked: {
            var songInfo = song.getSongInfo("input.mp3")
            console.log("Title: " + songInfo[0])
            console.log("Artist: " + songInfo[1])
            console.log("Album: " + songInfo[2])
        }
    }
}