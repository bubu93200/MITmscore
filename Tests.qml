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
// Copyright (C) 2022 Bruno Donati
//=============================================================================

// Fichiers de tests pour voir comment accéder à MuseScore

import QtQuick 2.2
//import QtQuick.Controls 2.0
import QtQuick.Controls 1.1 // avant il s'agissait de la version 2.0. Vérifier que cela fonctionne toujours.
import QtQuick.Controls.Styles 1.3 // Pour ?
import QtQuick.Layouts 1.1 // Pour ?
import QtQuick.Dialogs 1.1 // Pour ?
import MuseScore 3.0

Rectangle {
    width: 200
    height: 100
    color: "red"

    Text {
        anchors.centerIn: parent
        text: "Hello, World!"
    }
}
