/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Quick controls module of the Qt Toolkit.
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
import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Private 1.0

Item {
    id: editMenuBase
    anchors.fill: parent

    Component {
        id: cutAction
        Action {
            text: qsTr("Cu&t")
            shortcut: StandardKey.Cut
            iconName: "edit-cut"
            enabled: !input.readOnly && selectionStart !== selectionEnd
            onTriggered: {
                input.cut();
                input.select(input.cursorPosition, input.cursorPosition);
            }
        }
    }

    Component {
        id: copyAction
        Action {
            text: qsTr("&Copy")
            shortcut: StandardKey.Copy
            iconName: "edit-copy"
            enabled: input.selectionStart !== input.selectionEnd
            onTriggered: {
                input.copy();
                input.select(input.cursorPosition, input.cursorPosition);
            }
        }
    }

    Component {
        id: pasteAction
        Action {
            text: qsTr("&Paste")
            shortcut: StandardKey.Paste
            iconName: "edit-paste"
            enabled: input.canPaste
            onTriggered: input.paste()
        }
    }

    property Component defaultMenu: Menu {
        MenuItem { action: cutAction.createObject(editMenuBase) }
        MenuItem { action: copyAction.createObject(editMenuBase) }
        MenuItem { action: pasteAction.createObject(editMenuBase) }
    }

    Connections {
        target: mouseArea

        onClicked: {
            if (input.selectionStart === input.selectionEnd) {
                var cursorPos = input.positionAt(mouse.x, mouse.y)
                input.moveHandles(cursorPos, cursorPos)
            }

            input.activate()

            if (control.menu) {
                var menu = getMenuInstance();
                menu.__dismissMenu();
                menu.__destroyAllMenuPopups();
                var menuPos = mapToItem(null, mouse.x, mouse.y)
                menu.__popup(Qt.rect(menuPos.x, menuPos.y, 0, 0), -1, MenuPrivate.EditMenu);
            }
        }
    }
}
