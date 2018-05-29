/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
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

Style {
    readonly property SpinBox control: __control

    padding {
       top: control.__panel ? control.__panel.topPadding + (styleitem.style === "mac" ? 2 : 0) : 0
       left: control.__panel ? control.__panel.leftPadding : 0
       right: control.__panel ? control.__panel.rightPadding : 0
       bottom: control.__panel ? control.__panel.bottomPadding : 0
   }
    StyleItem {id: styleitem ; visible: false}

    property int renderType: Text.NativeRendering

    property Component panel: Item {
        id: style

        property rect upRect
        property rect downRect

        property int horizontalAlignment: Qt.platform.os === "osx" ? Qt.AlignRight : Qt.AlignLeft
        property int verticalAlignment: Qt.AlignVCenter

        property alias font: styleitem.font

        property color foregroundColor: SystemPaletteSingleton.text(control.enabled)
        property color backgroundColor: SystemPaletteSingleton.base(control.enabled)
        property color selectionColor: SystemPaletteSingleton.highlight(control.enabled)
        property color selectedTextColor: SystemPaletteSingleton.highlightedText(control.enabled)

        property int topPadding: edit.anchors.topMargin
        property int leftPadding: 3 + edit.anchors.leftMargin
        property int rightPadding: 3 + edit.anchors.rightMargin
        property int bottomPadding: edit.anchors.bottomMargin

        width: 100
        height: styleitem.implicitHeight

        implicitWidth: 2 + styleitem.implicitWidth
        implicitHeight: styleitem.implicitHeight
        baselineOffset: styleitem.baselineOffset

        Item {
            id: edit
            anchors.fill: parent
            FocusFrame {
                anchors.fill: parent
                focusMargin:-6
                visible: spinbox.activeFocus && styleitem.styleHint("focuswidget")
            }
        }

        function updateRect() {
            style.upRect = styleitem.subControlRect("up");
            style.downRect = styleitem.subControlRect("down");
            var inputRect = styleitem.subControlRect("edit");
            edit.anchors.topMargin = inputRect.y
            edit.anchors.leftMargin = inputRect.x
            edit.anchors.rightMargin = style.width - inputRect.width - edit.anchors.leftMargin
            edit.anchors.bottomMargin = style.height - inputRect.height - edit.anchors.topMargin
        }

        Component.onCompleted: updateRect()
        onWidthChanged: updateRect()
        onHeightChanged: updateRect()

        StyleItem {
            id: styleitem
            elementType: "spinbox"
            anchors.fill: parent
            sunken: (styleData.downEnabled && styleData.downPressed) || (styleData.upEnabled && styleData.upPressed)
            hover: control.hovered
            hints: control.styleHints
            hasFocus: control.activeFocus
            enabled: control.enabled
            value: (styleData.upPressed ? 1 : 0)           |
                   (styleData.downPressed ? 1<<1 : 0) |
                   (styleData.upEnabled ? (1<<2) : 0)      |
                   (styleData.downEnabled ? (1<<3) : 0)
            contentWidth: styleData.contentWidth
            contentHeight: styleData.contentHeight
            textureHeight: implicitHeight
            border {top: 6 ; bottom: 6}
        }
    }
}
