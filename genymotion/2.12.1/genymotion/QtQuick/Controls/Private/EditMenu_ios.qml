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
import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls.Private 1.0

Item {
    anchors.fill: parent
    property bool __showMenuFromTouchAndHold: false

    property Component defaultMenu: Menu {
        MenuItem {
            text: "cut"
            visible: !input.readOnly && selectionStart !== selectionEnd
            onTriggered: {
                cut();
                select(input.cursorPosition, input.cursorPosition);
            }
        }
        MenuItem {
            text: "copy"
            visible: selectionStart !== selectionEnd
            onTriggered: {
                copy();
                select(input.cursorPosition, input.cursorPosition);
            }
        }
        MenuItem {
            text: "paste"
            visible: input.canPaste
            onTriggered: paste();
        }
        MenuItem {
            text: "delete"
            visible: !input.readOnly && selectionStart !== selectionEnd
            onTriggered: remove(selectionStart, selectionEnd)
        }
        MenuItem {
            text: "select"
            visible: selectionStart === selectionEnd && input.length > 0
            onTriggered: selectWord();
        }
        MenuItem {
            text: "select all"
            visible: !(selectionStart === 0 && selectionEnd === length)
            onTriggered: selectAll();
        }
    }

    Connections {
        target: mouseArea

        function clearFocusFromOtherItems()
        {
            var selectionItem = TextSingleton.selectionItem;
            if (!selectionItem)
                return;
            var otherPos = selectionItem.cursorPosition;
            selectionItem.select(otherPos, otherPos)
        }

        onClicked: {
            if (control.menu && getMenuInstance().__popupVisible) {
                select(input.cursorPosition, input.cursorPosition);
            } else {
                input.activate();
                clearFocusFromOtherItems();
            }

            if (input.activeFocus) {
                var pos = input.positionAt(mouse.x, mouse.y)
                input.moveHandles(pos, pos)
            }
        }

        onPressAndHold: {
            var pos = input.positionAt(mouseArea.mouseX, mouseArea.mouseY);
            input.select(pos, pos);
            var hasSelection = selectionStart != selectionEnd;
            if (!control.menu || (input.length > 0 && (!input.activeFocus || hasSelection))) {
                selectWord();
            } else {
                // We don't select anything at this point, the
                // menu will instead offer to select a word.
                __showMenuFromTouchAndHold = true;
                menuTimer.start();
                clearFocusFromOtherItems();
            }
        }

        onReleased: __showMenuFromTouchAndHold = false
        onCanceled: __showMenuFromTouchAndHold = false
    }

    Connections {
        target: cursorHandle ? cursorHandle : null
        ignoreUnknownSignals: true
        onPressedChanged: menuTimer.start()
    }

    Connections {
        target: selectionHandle ? selectionHandle : null
        ignoreUnknownSignals: true
        onPressedChanged: menuTimer.start()
    }

    Connections {
        target: flickable
        ignoreUnknownSignals: true
        onMovingChanged: menuTimer.start()
    }

    Connections {
        id: selectionConnections
        target: input
        ignoreUnknownSignals: true
        onSelectionStartChanged: menuTimer.start()
        onSelectionEndChanged: menuTimer.start()
        onActiveFocusChanged: menuTimer.start()
    }

    Timer {
        // We use a timer so that we end up with one update when multiple connections fire at the same time.
        // Basically we wan't the menu to be open if the user does a press and hold, or if we have a selection.
        // The exceptions are if the user is moving selection handles or otherwise touching the screen (e.g flicking).
        // What is currently missing are showing a magnifyer to place the cursor, and to reshow the edit menu when
        // flicking stops.
        id: menuTimer
        interval: 1
        onTriggered: {
            if (!control.menu)
                return;

            if ((__showMenuFromTouchAndHold || selectionStart !== selectionEnd)
                    && control.activeFocus
                    && (!cursorHandle.pressed && !selectionHandle.pressed)
                    && (!flickable || !flickable.moving)
                    && (cursorHandle.delegate)) {
                var p1 = input.positionToRectangle(input.selectionStart);
                var p2 = input.positionToRectangle(input.selectionEnd);
                var topLeft = input.mapToItem(null, p1.x, p1.y);
                var size = Qt.size(p2.x - p1.x + p1.width, p2.y - p1.y + p1.height)
                var targetRect = Qt.rect(topLeft.x, topLeft.y, size.width, size.height);
                getMenuInstance().__dismissMenu();
                getMenuInstance().__popup(targetRect, -1, MenuPrivate.EditMenu);
            } else {
                getMenuInstance().__dismissMenu();
            }
        }
    }
}
