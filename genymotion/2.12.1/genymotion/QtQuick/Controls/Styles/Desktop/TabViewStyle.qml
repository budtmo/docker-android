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
import QtQuick.Controls.Styles 1.1
Style {
    id: root

    property bool tabsMovable: false
    property int tabsAlignment: __barstyle.styleHint("tabbaralignment") === "center" ? Qt.AlignHCenter : Qt.AlignLeft;
    property int tabOverlap: __barstyle.pixelMetric("taboverlap");
    property int frameOverlap: __barstyle.pixelMetric("tabbaseoverlap");

    property StyleItem __barstyle: StyleItem {
        elementType: "tab"
        properties: { "tabposition" : (control.tabPosition === Qt.TopEdge ? "Top" : "Bottom") }
        visible: false
    }

    property Component frame: StyleItem {
        id: styleitem
        anchors.fill: parent
        anchors.topMargin: 1//stack.baseOverlap
        z: style == "oxygen" ? 1 : 0
        elementType: "tabframe"
        value: tabbarItem && tabsVisible && tabbarItem.tab(currentIndex) ? tabbarItem.tab(currentIndex).x : 0
        minimum: tabbarItem && tabsVisible && tabbarItem.tab(currentIndex) ? tabbarItem.tab(currentIndex).width : 0
        maximum: tabbarItem && tabsVisible ? tabbarItem.width : width
        properties: { "selectedTabRect" : tabbarItem.__selectedTabRect, "orientation" : control.tabPosition }
        hints: control.styleHints
        Component.onCompleted: {
            stack.frameWidth = styleitem.pixelMetric("defaultframewidth");
            stack.style = style;
        }
        border{
            top: 16
            bottom: 16
        }
        textureHeight: 64
    }

    property Component tab: Item {
        id: item
        property string tabpos: control.count === 1 ? "only" : index === 0 ? "beginning" : index === control.count - 1 ? "end" : "middle"
        property string selectedpos: styleData.nextSelected ? "next" : styleData.previousSelected ? "previous" : ""
        property string orientation: control.tabPosition === Qt.TopEdge ? "Top" : "Bottom"
        property int tabHSpace: __barstyle.pixelMetric("tabhspace");
        property int tabVSpace: __barstyle.pixelMetric("tabvspace");
        property int totalOverlap: tabOverlap * (control.count - 1)
        property real maxTabWidth: control.count > 0 ? (control.width + totalOverlap) / control.count : 0
        implicitWidth: Math.min(maxTabWidth, Math.max(50, styleitem.textWidth(styleData.title)) + tabHSpace + 2)
        implicitHeight: Math.max(styleitem.font.pixelSize + tabVSpace + 6, 0)

        StyleItem {
            id: styleitem

            elementType: "tab"
            paintMargins: style === "mac" ? 0 : 2

            anchors.fill: parent
            anchors.topMargin: style === "mac" ? 2 : 0
            anchors.rightMargin: -paintMargins
            anchors.bottomMargin: -1
            anchors.leftMargin: -paintMargins + (style === "mac" && selected ? -1 : 0)
            properties: { "hasFrame" : true, "orientation": orientation, "tabpos": tabpos, "selectedpos": selectedpos }
            hints: control.styleHints

            enabled: styleData.enabled
            selected: styleData.selected
            text: elidedText(styleData.title, tabbarItem.elide, item.width - item.tabHSpace)
            hover: styleData.hovered
            hasFocus: tabbarItem.activeFocus && selected
        }
    }

    property Component leftCorner: null
    property Component rightCorner: null
}
