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
import QtQuick.Controls 1.2
import QtQuick.Controls.Private 1.0

Loader {
    id: handle

    property Item editor
    property int minimum: -1
    property int maximum: -1
    property int position: -1
    property alias delegate: handle.sourceComponent

    readonly property alias pressed: mouse.pressed

    readonly property real handleX: x + (item ? item.x : 0)
    readonly property real handleY: y + (item ? item.y : 0)
    readonly property real handleWidth: item ? item.width : 0
    readonly property real handleHeight: item ? item.height : 0

    property Item control
    property QtObject styleData: QtObject {
        id: styleData
        signal activated()
        readonly property alias pressed: mouse.pressed
        readonly property alias position: handle.position
        readonly property bool hasSelection: editor.selectionStart !== editor.selectionEnd
        readonly property real lineHeight: position !== -1 ? editor.positionToRectangle(position).height
                                                           : editor.cursorRectangle.height
    }

    function activate() {
        styleData.activated()
    }

    MouseArea {
        id: mouse
        anchors.fill: item
        enabled: item && item.visible
        preventStealing: true
        property real pressX
        property point offset
        property bool handleDragged: false

        onPressed: {
            Qt.inputMethod.commit()
            handleDragged = false
            pressX = mouse.x
            var handleRect = editor.positionToRectangle(handle.position)
            var centerX = handleRect.x + (handleRect.width / 2)
            var centerY = handleRect.y + (handleRect.height / 2)
            var center = mapFromItem(editor, centerX, centerY)
            offset = Qt.point(mouseX - center.x, mouseY - center.y)
        }
        onReleased: {
            if (!handleDragged) {
                // The user just clicked on the handle. In that
                // case clear the selection.
                var mousePos = editor.mapFromItem(item, mouse.x, mouse.y)
                var editorPos = editor.positionAt(mousePos.x, mousePos.y)
                editor.select(editorPos, editorPos)
            }
        }
        onPositionChanged: {
            handleDragged = true
            var pt = mapToItem(editor, mouse.x - offset.x, mouse.y - offset.y)

            // limit vertically within mix/max coordinates or content bounds
            var min = (minimum !== -1) ? minimum : 0
            var max = (maximum !== -1) ? maximum : editor.length
            pt.y = Math.max(pt.y, editor.positionToRectangle(min).y)
            pt.y = Math.min(pt.y, editor.positionToRectangle(max).y)

            var pos = editor.positionAt(pt.x, pt.y)

            // limit horizontally within min/max character positions
            if (minimum !== -1)
                pos = Math.max(pos, minimum)
            pos = Math.max(pos, 0)
            if (maximum !== -1)
                pos = Math.min(pos, maximum)
            pos = Math.min(pos, editor.length)

            handle.position = pos
        }
    }
}
