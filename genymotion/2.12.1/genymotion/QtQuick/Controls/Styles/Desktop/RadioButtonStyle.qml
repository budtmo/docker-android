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
    readonly property RadioButton control: __control
    property Component panel: Item {
        anchors.fill: parent

        implicitWidth:  styleitem.implicitWidth
        implicitHeight: styleitem.implicitHeight
        baselineOffset: styleitem.baselineOffset

        StyleItem {
            id: styleitem
            elementType: "radiobutton"
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: macStyle ? -1 : 0
            sunken: control.pressed
            on: control.checked || control.pressed
            hover: control.hovered
            enabled: control.enabled
            hasFocus: control.activeFocus && styleitem.style == "mac"
            hints: control.styleHints
            contentHeight: textitem.implicitHeight
            contentWidth: Math.ceil(textitem.implicitWidth) + 4
            property int indicatorWidth: pixelMetric("indicatorwidth") + (macStyle ? 2 : 4)
            property bool macStyle: (style === "mac")

            Text {
                id: textitem
                text: control.text
                anchors.left: parent.left
                anchors.leftMargin: parent.indicatorWidth
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.macStyle ? 2 : 0
                anchors.right: parent.right
                renderType: Text.NativeRendering
                elide: Text.ElideRight
                enabled: control.enabled
                color: SystemPaletteSingleton.windowText(control.enabled)
                StyleItem {
                    elementType: "focusrect"
                    anchors.margins: -1
                    anchors.leftMargin: -2
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: textitem.implicitWidth + 3
                    visible: control.activeFocus
                }
            }
        }
    }
}
