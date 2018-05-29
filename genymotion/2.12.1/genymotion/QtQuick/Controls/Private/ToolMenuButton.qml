/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Private 1.0

FocusScope {
    id: button

    property Menu menu
    readonly property bool pressed: behavior.containsPress || behavior.keyPressed
    readonly property alias hovered: behavior.containsMouse

    property alias panel: loader.sourceComponent
    property alias __panel: loader.item

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    implicitWidth: __panel ? __panel.implicitWidth : 0
    implicitHeight: __panel ? __panel.implicitHeight : 0

    Loader {
        id: loader
        anchors.fill: parent
        property QtObject styleData: QtObject {
            readonly property alias pressed: button.pressed
            readonly property alias hovered: button.hovered
            readonly property alias activeFocus: button.activeFocus
        }
        onStatusChanged: if (status === Loader.Error) console.error("Failed to load Style for", button)
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Space && !event.isAutoRepeat && !behavior.keyPressed)
            behavior.keyPressed = true
    }
    Keys.onReleased: {
        if (event.key === Qt.Key_Space && !event.isAutoRepeat && behavior.keyPressed)
            behavior.keyPressed = false
    }
    onFocusChanged: {
        if (!focus)
            behavior.keyPressed = false
    }
    onPressedChanged: {
        if (!Settings.hasTouchScreen && !pressed && menu)
            popupMenuTimer.start()
    }

    MouseArea {
        id: behavior
        property bool keyPressed: false

        anchors.fill: parent
        enabled: !keyPressed
        hoverEnabled: Settings.hoverEnabled

        onReleased: {
            if (Settings.hasTouchScreen && containsMouse && menu)
                popupMenuTimer.start()
        }

        Timer {
            id: popupMenuTimer
            interval: 10
            onTriggered: {
                behavior.keyPressed = false
                if (Qt.application.layoutDirection === Qt.RightToLeft)
                    menu.__popup(Qt.rect(button.width, button.height, 0, 0), 0)
                else
                    menu.__popup(Qt.rect(0, 0, button.width, button.height), 0)
            }
        }
    }

    Binding {
        target: menu
        property: "__minimumWidth"
        value: button.width
    }

    Binding {
        target: menu
        property: "__visualItem"
        value: button
    }
}
