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
import QtQuick 2.2
import QtQuick.Controls.Private 1.0

TextInput {
    id: input

    property Item control
    property alias cursorHandle: cursorHandle.delegate
    property alias selectionHandle: selectionHandle.delegate

    property bool blockRecursion: false
    property bool hasSelection: selectionStart !== selectionEnd
    readonly property int selectionPosition: selectionStart !== cursorPosition ? selectionStart : selectionEnd
    readonly property alias containsMouse: mouseArea.containsMouse
    property alias editMenu: editMenu
    cursorDelegate: __style && __style.__cursorDelegate ? __style.__cursorDelegate : null

    selectByMouse: control.selectByMouse && (!Settings.isMobile || !cursorHandle.delegate || !selectionHandle.delegate)

    // force re-evaluation when selection moves:
    // - cursorRectangle changes => content scrolled
    // - contentWidth changes => text layout changed
    property rect selectionRectangle: cursorRectangle.x && contentWidth ? positionToRectangle(selectionPosition)
                                                                        : positionToRectangle(selectionPosition)

    onSelectionStartChanged: syncHandlesWithSelection()
    onCursorPositionChanged: syncHandlesWithSelection()

    function syncHandlesWithSelection()
    {
        if (!blockRecursion && selectionHandle.delegate) {
            blockRecursion = true
            // We cannot use property selectionPosition since it gets updated after onSelectionStartChanged
            cursorHandle.position = cursorPosition
            selectionHandle.position = (selectionStart !== cursorPosition) ? selectionStart : selectionEnd
            blockRecursion = false
        }
        TextSingleton.updateSelectionItem(input)
    }

    function activate() {
        if (activeFocusOnPress) {
            forceActiveFocus()
            if (!readOnly)
                Qt.inputMethod.show()
        }
        cursorHandle.activate()
        selectionHandle.activate()
    }

    function moveHandles(cursor, selection) {
        blockRecursion = true
        cursorPosition = cursor
        if (selection === -1) {
            selectWord()
            selection = selectionStart
        }
        selectionHandle.position = selection
        cursorHandle.position = cursorPosition
        blockRecursion = false
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: Settings.hoverEnabled
        cursorShape: Qt.IBeamCursor
        acceptedButtons: (input.selectByMouse ? Qt.NoButton : Qt.LeftButton) | (control.menu ? Qt.RightButton : Qt.NoButton)
        onClicked: {
            if (editMenu.item)
                return;
            var pos = input.positionAt(mouse.x, mouse.y)
            input.moveHandles(pos, pos)
            input.activate()
        }
        onPressAndHold: {
            if (editMenu.item)
                return;
            var pos = input.positionAt(mouse.x, mouse.y)
            input.moveHandles(pos, control.selectByMouse ? -1 : pos)
            input.activate()
        }
    }

    EditMenu {
        id: editMenu
        input: parent
        mouseArea: mouseArea
        control: parent.control
        cursorHandle: cursorHandle
        selectionHandle: selectionHandle
        anchors.fill: parent
    }

    TextHandle {
        id: selectionHandle

        editor: input
        parent: control
        control: input.control
        active: control.selectByMouse && Settings.isMobile
        maximum: cursorHandle.position - 1

        property var mappedPos: parent.mapFromItem(editor, editor.selectionRectangle.x, editor.selectionRectangle.y)
        x: mappedPos.x
        y: mappedPos.y

        visible: pressed || (input.hasSelection && handleX + handleWidth >= -1 && handleX <= control.width + 1)

        onPositionChanged: {
            if (!input.blockRecursion) {
                input.blockRecursion = true
                input.select(selectionHandle.position, cursorHandle.position)
                if (pressed)
                    input.ensureVisible(position)
                input.blockRecursion = false
            }
        }
    }

    TextHandle {
        id: cursorHandle

        editor: input
        parent: control
        control: input.control
        active: control.selectByMouse && Settings.isMobile
        minimum: input.hasSelection ? selectionHandle.position + 1 : -1

        property var mappedPos: parent.mapFromItem(editor, editor.cursorRectangle.x, editor.cursorRectangle.y)
        x: mappedPos.x
        y: mappedPos.y

        visible: pressed || ((input.cursorVisible || input.hasSelection) && handleX + handleWidth >= -1 && handleX <= control.width + 1)

        onPositionChanged: {
            if (!input.blockRecursion) {
                input.blockRecursion = true
                if (!input.hasSelection)
                    selectionHandle.position = cursorHandle.position
                input.select(selectionHandle.position, cursorHandle.position)
                input.blockRecursion = false
            }
        }
    }
}
