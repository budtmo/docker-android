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
    property int renderType: Text.NativeRendering

    property Component panel: StyleItem {
        id: textfieldstyle
        elementType: "edit"
        anchors.fill: parent

        sunken: true
        hasFocus: control.activeFocus
        hover: hovered
        hints: control.styleHints

        property color textColor: SystemPaletteSingleton.text(control.enabled)
        property color placeholderTextColor: "darkGray"
        property color selectionColor: SystemPaletteSingleton.highlight(control.enabled)
        property color selectedTextColor: SystemPaletteSingleton.highlightedText(control.enabled)


        property bool rounded: !!hints["rounded"]
        property int topMargin: style === "mac" ? 3 : 2
        property int leftMargin: rounded ? 12 : 4
        property int rightMargin: leftMargin
        property int bottomMargin: 2

        contentWidth: 100
        // Form QLineEdit::sizeHint
        contentHeight: Math.max(control.__contentHeight, 16)

        FocusFrame {
            anchors.fill: parent
            visible: textfield.activeFocus && textfieldstyle.styleHint("focuswidget") && !rounded
        }
        textureHeight: implicitHeight
        textureWidth: 32
        border {top: 8 ; bottom: 8 ; left: 8 ; right: 8}
    }
}
