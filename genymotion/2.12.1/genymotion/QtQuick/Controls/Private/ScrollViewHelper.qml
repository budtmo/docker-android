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
        \qmltype ScrollViewHeader
        \internal
        \inqmlmodule QtQuick.Controls.Private
*/
Item {
    id: wheelarea

    property alias horizontalScrollBar: hscrollbar
    property alias verticalScrollBar: vscrollbar
    property bool blockUpdates: false
    property int availableHeight
    property int availableWidth
    property int contentHeight
    property int contentWidth
    property real originX
    property real originY
    property bool active
    property int horizontalScrollBarPolicy: Qt.ScrollBarAsNeeded
    property int verticalScrollBarPolicy: Qt.ScrollBarAsNeeded


    property int leftMargin: outerFrame ? root.__style.padding.left : 0
    property int rightMargin: outerFrame ? root.__style.padding.right : 0
    property int topMargin: outerFrame ? root.__style.padding.top : 0
    property int bottomMargin: outerFrame ? root.__style.padding.bottom : 0

    anchors.fill: parent

    property bool recursionGuard: false

    function doLayout() {
        if (!recursionGuard) {
            recursionGuard = true
            wheelarea.availableWidth = viewport.width
            wheelarea.availableHeight = viewport.height
            wheelarea.contentWidth = flickableItem !== null ? flickableItem.contentWidth : 0
            wheelarea.contentHeight = flickableItem !== null ? flickableItem.contentHeight : 0
            wheelarea.originX = flickableItem !== null ? flickableItem.originX : 0
            wheelarea.originY = flickableItem !== null ? flickableItem.originY : 0
            recursionGuard = false
        }
    }

    Connections {
        target: viewport
        onWidthChanged: doLayout()
        onHeightChanged: doLayout()
    }

    Connections {
        target: flickableItem
        onContentWidthChanged: doLayout()
        onContentHeightChanged: doLayout()
    }

    Connections {
        target: flickableItem
        onContentXChanged: {
            hscrollbar.flash()
            vscrollbar.flash()
        }
        onContentYChanged: {
            hscrollbar.flash()
            vscrollbar.flash()
        }
    }

    Loader {
        id: cornerFill
        z: 1
        sourceComponent: __style.corner
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: bottomMargin
        anchors.rightMargin: rightMargin
        width: visible ? vscrollbar.width : 0
        height: visible ? hscrollbar.height : 0
        visible: hscrollbar.visible && !hscrollbar.isTransient && vscrollbar.visible && !vscrollbar.isTransient
    }

    ScrollBar {
        id: hscrollbar
        isTransient: !!__panel && !!__panel.isTransient
        active: !!__panel && (__panel.sunken || __panel.activeControl !== "none")
        enabled: !isTransient || __panel.visible
        orientation: Qt.Horizontal
        visible: horizontalScrollBarPolicy ==  Qt.ScrollBarAsNeeded ? (contentWidth > availableWidth) : horizontalScrollBarPolicy == Qt.ScrollBarAlwaysOn
        height: visible ? implicitHeight : 0
        z: 1
        maximumValue: contentWidth > availableWidth ? originX + contentWidth - availableWidth : 0
        minimumValue: originX
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: cornerFill.left
        anchors.leftMargin:  leftMargin
        anchors.bottomMargin: bottomMargin
        onValueChanged: {
            if (!blockUpdates) {
                flickableItem.contentX = value
            }
        }
        Binding {
            target: hscrollbar.__panel
            property: "raised"
            value: vscrollbar.active || wheelarea.active
            when: hscrollbar.isTransient
        }
        Binding {
            target: hscrollbar.__panel
            property: "visible"
            value: true
            when: !hscrollbar.isTransient || wheelarea.active
        }
        function flash() {
            if (hscrollbar.isTransient) {
                hscrollbar.__panel.on = true
                hscrollbar.__panel.visible = true
                hFlasher.start()
            }
        }
        Timer {
            id: hFlasher
            interval: 10
            onTriggered: hscrollbar.__panel.on = false
        }
    }

    ScrollBar {
        id: vscrollbar
        isTransient: !!__panel && !!__panel.isTransient
        active: !!__panel && (__panel.sunken || __panel.activeControl !== "none")
        enabled: !isTransient || __panel.visible
        orientation: Qt.Vertical
        visible: verticalScrollBarPolicy ==  Qt.ScrollBarAsNeeded ? (contentHeight > availableHeight) : verticalScrollBarPolicy == Qt.ScrollBarAlwaysOn
        width: visible ? implicitWidth : 0
        z: 1
        anchors.bottom: cornerFill.top
        maximumValue: contentHeight > availableHeight ? originY + contentHeight - availableHeight + __viewTopMargin : 0
        minimumValue: originY
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: __scrollBarTopMargin + topMargin
        anchors.rightMargin: rightMargin
        onValueChanged: {
            if (flickableItem && !blockUpdates && enabled) {
                flickableItem.contentY = value
            }
        }
        Binding {
            target: vscrollbar.__panel
            property: "raised"
            value: hscrollbar.active || wheelarea.active
            when: vscrollbar.isTransient
        }
        Binding {
            target: vscrollbar.__panel
            property: "visible"
            value: true
            when: !vscrollbar.isTransient || wheelarea.active
        }
        function flash() {
            if (vscrollbar.isTransient) {
                vscrollbar.__panel.on = true
                vscrollbar.__panel.visible = true
                vFlasher.start()
            }
        }
        Timer {
            id: vFlasher
            interval: 10
            onTriggered: vscrollbar.__panel.on = false
        }
    }
}
