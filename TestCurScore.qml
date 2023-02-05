import MuseScore       3.0 // not working - "buggy"
//import MuseScore       1.0 // working - no "bug" 
import QtQuick         2.3
import QtQuick.Dialogs 1.2

MuseScore {
	id: idMuseScore;

	property var pluginName: qsTr("Test curScore")
	menuPath:                "Plugins." + pluginName
	description:             "show curScore 'bug' (MuseScore 3)"
	
	property var oldScore: null;
	
	Dialog {
		id:             idDialog
		title:          pluginName
		visible:        true
		onAccepted: {
			Qt.quit();
		}
		Timer {
			interval: 100;
			running:  true;
			repeat:   true;
			onTriggered: {
				if (oldScore != curScore) {
					console.log("oldScore: " + oldScore);
					console.log("curScore: " + curScore);
					oldScore = curScore;
				}
			}
		}
	}
}