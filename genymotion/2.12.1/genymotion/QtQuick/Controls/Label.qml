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
    \qmltype Label
    \inqmlmodule QtQuick.Controls
    \since 5.1
    \ingroup controls
    \brief A text label.

    \image label.png

    In addition to the normal \l Text type, Label follows the font and
    color scheme of the system.
    Use the \c text property to assign a text to the label. For other properties
    check \l Text.

    A simple label looks like this:
    \qml
    Label {
        text: "Hello world"
    }
    \endqml

    You can use the properties of \l Text to change the appearance
    of the text as desired:
    \qml
    Label {
        text: "Hello world"
        font.pixelSize: 22
        font.italic: true
        color: "steelblue"
    }
    \endqml

    \sa Text, TextField, TextEdit
*/

Text {
    /*!
        \qmlproperty string Label::text

        The text to display. Use this property to get and set it.
    */

    id: label
    color: pal.windowText
    activeFocusOnTab: false
    renderType: Settings.isMobile ? Text.QtRendering : Text.NativeRendering
    SystemPalette {
        id: pal
        colorGroup: enabled ? SystemPalette.Active : SystemPalette.Disabled
    }
    Accessible.name: text
    Accessible.role: Accessible.StaticText
}
