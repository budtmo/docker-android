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
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls.Private 1.0

/*!
    \qmltype MenuBar
    \inqmlmodule QtQuick.Controls
    \since 5.1
    \ingroup applicationwindow
    \brief Provides a horizontal menu bar.

    \image menubar.png

    MenuBar can be added to an \l ApplicationWindow, providing menu options
    to access additional functionality of the application.

    \code
    ApplicationWindow {
        ...
        menuBar: MenuBar {
            Menu {
                title: "File"
                MenuItem { text: "Open..." }
                MenuItem { text: "Close" }
            }

            Menu {
                title: "Edit"
                MenuItem { text: "Cut" }
                MenuItem { text: "Copy" }
                MenuItem { text: "Paste" }
            }
        }
    }
    \endcode

    \sa ApplicationWindow::menuBar
*/

MenuBarPrivate {
    id: root

    property Component style: Qt.createComponent(Settings.style + "/MenuBarStyle.qml", root)

    /*! \internal */
    property QtObject __style: styleLoader.item

    __isNative: !__style.hasOwnProperty("__isNative") || __style.__isNative

    /*! \internal */
    __contentItem: Loader {
        id: topLoader
        sourceComponent: __menuBarComponent
        active: !root.__isNative
        focus: true
        Keys.forwardTo: [item]
        property real preferredWidth: parent && active ? parent.width : 0
        property bool altPressed: item ? item.__altPressed : false

        Loader {
            id: styleLoader
            property alias __control: topLoader.item
            sourceComponent: root.style
            onStatusChanged: {
                if (status === Loader.Error)
                    console.error("Failed to load Style for", root)
            }
        }
    }

    /*! \internal */
    property Component __menuBarComponent: Loader {
        id: menuBarLoader


        onStatusChanged: if (status === Loader.Error) console.error("Failed to load panel for", root)

        visible: status === Loader.Ready
        sourceComponent: d.style ? d.style.background : undefined

        width: implicitWidth || root.__contentItem.preferredWidth
        height: Math.max(row.height + d.heightPadding, item ? item.implicitHeight : 0)

        Binding {
            // Make sure the styled menu bar is in the background
            target: menuBarLoader.item
            property: "z"
            value: menuMouseArea.z - 1
        }

        QtObject {
            id: d

            property Style style: __style

            property int openedMenuIndex: -1
            property bool preselectMenuItem: false
            property real heightPadding: style ? style.padding.top + style.padding.bottom : 0

            property bool altPressed: false
            property bool altPressedAgain: false
            property var mnemonicsMap: ({})

            function dismissActiveFocus(event, reason) {
                if (reason) {
                    altPressedAgain = false
                    altPressed = false
                    openedMenuIndex = -1
                    root.__contentItem.parent.forceActiveFocus()
                } else {
                    event.accepted = false
                }
            }

            function maybeOpenFirstMenu(event) {
                if (altPressed && openedMenuIndex === -1) {
                    preselectMenuItem = true
                    openedMenuIndex = 0
                } else {
                    event.accepted = false
                }
            }
        }
        property alias __altPressed: d.altPressed // Needed for the menu contents

        focus: true

        Keys.onPressed: {
            var action = null
            if (event.key === Qt.Key_Alt) {
                if (!d.altPressed)
                    d.altPressed = true
                else
                    d.altPressedAgain = true
            } else if (d.altPressed && (action = d.mnemonicsMap[event.text.toUpperCase()])) {
                d.preselectMenuItem = true
                action.trigger()
                event.accepted = true
            }
        }

        Keys.onReleased: d.dismissActiveFocus(event, d.altPressedAgain && d.openedMenuIndex === -1)
        Keys.onEscapePressed: d.dismissActiveFocus(event, d.openedMenuIndex === -1)

        Keys.onUpPressed: d.maybeOpenFirstMenu(event)
        Keys.onDownPressed: d.maybeOpenFirstMenu(event)

        Keys.onLeftPressed: {
            if (d.openedMenuIndex > 0) {
                var idx = d.openedMenuIndex - 1
                while (idx >= 0 && !(root.menus[idx].enabled && root.menus[idx].visible))
                    idx--
                if (idx >= 0) {
                    d.preselectMenuItem = true
                    d.openedMenuIndex = idx
                }
            } else {
                event.accepted = false;
            }
        }

        Keys.onRightPressed: {
            if (d.openedMenuIndex !== -1 && d.openedMenuIndex < root.menus.length - 1) {
                var idx = d.openedMenuIndex + 1
                while (idx < root.menus.length && !(root.menus[idx].enabled && root.menus[idx].visible))
                    idx++
                if (idx < root.menus.length) {
                    d.preselectMenuItem = true
                    d.openedMenuIndex = idx
                }
            } else {
                event.accepted = false;
            }
        }

        Row {
            id: row
            x: d.style ? d.style.padding.left : 0
            y: d.style ? d.style.padding.top : 0
            width: parent.width - (d.style ? d.style.padding.left + d.style.padding.right : 0)
            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft

            Repeater {
                id: itemsRepeater
                model: root.menus
                Loader {
                    id: menuItemLoader

                    property var styleData: QtObject {
                        readonly property int index: __menuItemIndex
                        readonly property string text: !!__menuItem && __menuItem.title
                        readonly property bool enabled: !!__menuItem && __menuItem.enabled
                        readonly property bool selected: menuMouseArea.hoveredItem === menuItemLoader
                        readonly property bool open: !!__menuItem && __menuItem.__popupVisible || d.openedMenuIndex === index
                        readonly property bool underlineMnemonic: d.altPressed
                    }

                    height: Math.max(menuBarLoader.height - d.heightPadding,
                                     menuItemLoader.item ? menuItemLoader.item.implicitHeight : 0)

                    readonly property var __menuItem: modelData
                    readonly property int __menuItemIndex: index
                    sourceComponent: d.style ? d.style.itemDelegate : null
                    visible: __menuItem.visible

                    Connections {
                        target: d
                        onOpenedMenuIndexChanged: {
                            if (!__menuItem.enabled)
                                return;
                            if (d.openedMenuIndex === index) {
                                if (__menuItem.__usingDefaultStyle)
                                    __menuItem.style = d.style.menuStyle
                                __menuItem.__popup(Qt.rect(row.LayoutMirroring.enabled ? menuItemLoader.width : 0,
                                                   menuBarLoader.height - d.heightPadding, 0, 0), 0)
                                if (d.preselectMenuItem)
                                    __menuItem.__currentIndex = 0
                            } else if (__menuItem.__popupVisible) {
                                __menuItem.__dismissMenu()
                                __menuItem.__destroyAllMenuPopups()
                            }
                        }
                    }

                    Connections {
                        target: __menuItem
                        onPopupVisibleChanged: {
                            if (!__menuItem.__popupVisible && d.openedMenuIndex === index)
                                d.openedMenuIndex = -1
                        }
                    }

                    Connections {
                        target: __menuItem.__action
                        onTriggered: d.openedMenuIndex = __menuItemIndex
                    }

                    Component.onCompleted: {
                        __menuItem.__visualItem = menuItemLoader

                        var title = __menuItem.title
                        var ampersandPos = title.indexOf("&")
                        if (ampersandPos !== -1)
                            d.mnemonicsMap[title[ampersandPos + 1].toUpperCase()] = __menuItem.__action
                    }
                }
            }
        }

        MouseArea {
            id: menuMouseArea
            anchors.fill: parent
            hoverEnabled: Settings.hoverEnabled

            onPositionChanged: updateCurrentItem(mouse, false)
            onPressed: {
                if (updateCurrentItem(mouse)) {
                    d.preselectMenuItem = false
                    d.openedMenuIndex = currentItem.__menuItemIndex
                }
            }
            onExited: hoveredItem = null

            property Item currentItem: null
            property Item hoveredItem: null
            function updateCurrentItem(mouse) {
                var pos = mapToItem(row, mouse.x, mouse.y)
                if (!hoveredItem || !hoveredItem.contains(Qt.point(pos.x - currentItem.x, pos.y - currentItem.y))) {
                    hoveredItem = row.childAt(pos.x, pos.y)
                    if (!hoveredItem)
                        return false;
                    currentItem = hoveredItem
                    if (d.openedMenuIndex !== -1) {
                        d.preselectMenuItem = false
                        d.openedMenuIndex = currentItem.__menuItemIndex
                    }
                }
                return true;
            }
        }
    }
}
