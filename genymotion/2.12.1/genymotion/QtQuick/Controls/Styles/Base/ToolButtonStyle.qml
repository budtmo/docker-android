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

/*!
    \qmltype ToolButtonStyle
    \internal
    \ingroup controlsstyling
    \inqmlmodule QtQuick.Controls.Styles
*/
Style {
    readonly property ToolButton control: __control
    property Component panel: Item {
        id: styleitem
        implicitWidth: (hasIcon ? icon.width : Math.max(label.implicitWidth + frame.border.left + frame.border.right, 36))
                                 + (arrow.visible ? 10 : 0)
        implicitHeight: hasIcon ? icon.height : Math.max(label.implicitHeight, 36)

        readonly property bool hasIcon: icon.status === Image.Ready || icon.status === Image.Loading

        Rectangle {
            anchors.fill: parent
            visible: control.pressed || (control.checkable && control.checked)
            color: "lightgray"
            radius:4
            border.color: "#aaa"
        }
        Item {
            anchors.left: parent.left
            anchors.right: arrow.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            clip: true
            Text {
                id: label
                visible: !hasIcon
                anchors.centerIn: parent
                text: StyleHelpers.stylizeMnemonics(control.text)
                renderType: Settings.isMobile ? Text.QtRendering : Text.NativeRendering
            }
            Image {
                id: icon
                anchors.centerIn: parent
                source: control.iconSource
            }
        }

        BorderImage {
            id: frame
            anchors.fill: parent
            anchors.margins: -1
            anchors.topMargin: -2
            anchors.rightMargin: 0
            source: "images/focusframe.png"
            visible: control.activeFocus
            border.left: 4
            border.right: 4
            border.top: 4
            border.bottom: 4
        }

        Image {
            id: arrow
            visible: control.menu !== null
            source: visible ? "images/arrow-down.png" : ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: visible ? 3 : 0
            opacity: control.enabled ? 0.7 : 0.5
        }
    }
}
