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
    id: root

    padding {
        property int frameWidth: __styleitem.pixelMetric("defaultframewidth")
        left: frameWidth
        top: frameWidth
        bottom: frameWidth
        right: frameWidth
    }

    property StyleItem __styleitem: StyleItem { elementType: "frame" }

    property Component frame: StyleItem {
        id: styleitem
        elementType: "frame"
        sunken: true
        visible: control.frameVisible
        textureHeight: 64
        textureWidth: 64
        border {
            top: 16
            left: 16
            right: 16
            bottom: 16
        }
    }

    property Component corner: StyleItem { elementType: "scrollareacorner" }

    readonly property bool __externalScrollBars: __styleitem.styleHint("externalScrollBars")
    readonly property int __scrollBarSpacing: __styleitem.pixelMetric("scrollbarspacing")
    readonly property bool scrollToClickedPosition: __styleitem.styleHint("scrollToClickPosition") !== 0

    property Component __scrollbar: StyleItem {
        anchors.fill:parent
        elementType: "scrollbar"
        hover: activeControl != "none"
        activeControl: "none"
        sunken: __styleData.upPressed | __styleData.downPressed | __styleData.handlePressed
        minimum: __control.minimumValue
        maximum: __control.maximumValue
        value: __control.value
        horizontal: __styleData.horizontal
        enabled: __control.enabled

        implicitWidth: horizontal ? 200 : pixelMetric("scrollbarExtent")
        implicitHeight: horizontal ? pixelMetric("scrollbarExtent") : 200
    }

}
