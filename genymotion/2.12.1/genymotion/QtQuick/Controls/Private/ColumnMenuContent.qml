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

Item {
    id: content

    property Component menuItemDelegate
    property Component scrollIndicatorStyle
    property Component scrollerStyle
    property var itemsModel
    property int minWidth: 100
    property real maxHeight: 800
    readonly property bool mousePressed: hoverArea.pressed

    signal triggered(var item)

    function menuItemAt(index) {
        list.currentIndex = index
        return list.currentItem
    }

    width: Math.max(list.contentWidth, minWidth)
    height: Math.min(list.contentHeight, fittedMaxHeight)

    readonly property int currentIndex: __menu.__currentIndex
    property Item currentItem: null
    property int itemHeight: 23

    Component.onCompleted: {
        var children = list.contentItem.children
        for (var i = 0; i < list.count; i++) {
            var child = children[i]
            if (child.visible && child.styleData.type === MenuItemType.Item) {
                itemHeight = children[i].height
                break
            }
        }
    }

    readonly property int fittingItems: Math.floor((maxHeight - downScroller.height) / itemHeight)
    readonly property real fittedMaxHeight: itemHeight * fittingItems + downScroller.height
    readonly property bool shouldUseScrollers: scrollView.style === emptyScrollerStyle && itemsModel.length > fittingItems
    readonly property real upScrollerHeight: upScroller.visible ? upScroller.height : 0
    readonly property real downScrollerHeight: downScroller.visible ? downScroller.height : 0
    property var oldMousePos: undefined
    property var openedSubmenu: null

    function updateCurrentItem(mouse) {
        var pos = mapToItem(list.contentItem, mouse.x, mouse.y)
        var dx = 0
        var dy = 0
        var dist = 0
        if (openedSubmenu && oldMousePos !== undefined) {
            dx = mouse.x - oldMousePos.x
            dy = mouse.y - oldMousePos.y
            dist = Math.sqrt(dx * dx + dy * dy)
        }
        oldMousePos = mouse
        if (openedSubmenu && dist > 5) {
            var menuRect = __menu.__popupGeometry
            var submenuRect = openedSubmenu.__popupGeometry
            var angle = Math.atan2(dy, dx)
            var ds = 0
            if (submenuRect.x > menuRect.x) {
                ds = menuRect.width - oldMousePos.x
            } else {
                angle = Math.PI - angle
                ds = oldMousePos.x
            }
            var above = submenuRect.y - menuRect.y - oldMousePos.y
            var below = submenuRect.height - above
            var minAngle = Math.atan2(above, ds)
            var maxAngle = Math.atan2(below, ds)
            // This tests that the current mouse position is in
            // the triangle defined by the previous mouse position
            // and the submenu's top-left and bottom-left corners.
            if (minAngle < angle && angle < maxAngle) {
                sloppyTimer.start()
                return
            }
        }

        if (!currentItem || !currentItem.contains(Qt.point(pos.x - currentItem.x, pos.y - currentItem.y))) {
            if (currentItem && !hoverArea.pressed
                && currentItem.styleData.type === MenuItemType.Menu) {
                currentItem.__closeSubMenu()
                openedSubmenu = null
            }
            currentItem = list.itemAt(pos.x, pos.y)
            if (currentItem) {
                __menu.__currentIndex = currentItem.__menuItemIndex
                if (currentItem.styleData.type === MenuItemType.Menu
                    && !currentItem.__menuItem.__popupVisible) {
                    currentItem.__showSubMenu(false)
                    openedSubmenu = currentItem.__menuItem
                }
            } else {
                __menu.__currentIndex = -1
            }
        }
    }

    Timer {
        id: sloppyTimer
        interval: 1000

        // Stop timer as soon as we hover one of the submenu items
        property int currentIndex: openedSubmenu ? openedSubmenu.__currentIndex : -1
        onCurrentIndexChanged: if (currentIndex !== -1) stop()

        onTriggered: {
            if (openedSubmenu && openedSubmenu.__currentIndex === -1)
                updateCurrentItem(oldMousePos)
        }
    }

    Component {
        id: emptyScrollerStyle
        Style {
            padding { left: 0; right: 0; top: 0; bottom: 0 }
            property bool scrollToClickedPosition: false
            property Component frame: Item { visible: false }
            property Component corner: Item { visible: false }
            property Component __scrollbar: Item { visible: false }
        }
    }

    ScrollView {
        id: scrollView
        anchors {
            fill: parent
            topMargin: upScrollerHeight
            bottomMargin: downScrollerHeight
        }

        style: scrollerStyle || emptyScrollerStyle
        __wheelAreaScrollSpeed: itemHeight

        ListView {
            id: list
            model: itemsModel
            delegate: menuItemDelegate
            snapMode: ListView.SnapToItem
            boundsBehavior: Flickable.StopAtBounds
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0
        }
    }

    MouseArea {
        id: hoverArea
        anchors.left: scrollView.left
        width: scrollView.width - scrollView.__verticalScrollBar.width
        height: parent.height

        hoverEnabled: Settings.hoverEnabled
        acceptedButtons: Qt.AllButtons

        onPositionChanged: updateCurrentItem({ "x": mouse.x, "y": mouse.y })
        onPressed: updateCurrentItem({ "x": mouse.x, "y": mouse.y })
        onReleased: content.triggered(currentItem)
        onExited: {
            if (currentItem && !currentItem.__menuItem.__popupVisible) {
                currentItem = null
                __menu.__currentIndex = -1
            }
        }

        MenuContentScroller {
            id: upScroller
            direction: Qt.UpArrow
            visible: shouldUseScrollers && !list.atYBeginning
            function scrollABit() { list.contentY -= itemHeight }
        }

        MenuContentScroller {
            id: downScroller
            direction: Qt.DownArrow
            visible: shouldUseScrollers && !list.atYEnd
            function scrollABit() { list.contentY += itemHeight }
        }
    }

    Timer {
        interval: 1
        running: true
        repeat: false
        onTriggered: list.positionViewAtIndex(currentIndex, !scrollView.__style
                                                            ? ListView.Center : ListView.Beginning)
    }

    Binding {
        target: scrollView.__verticalScrollBar
        property: "singleStep"
        value: itemHeight
    }
}
