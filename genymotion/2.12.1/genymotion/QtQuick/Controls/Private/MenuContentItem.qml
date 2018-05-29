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

Loader {
    id: menuFrameLoader

    property var __menu

    visible: status === Loader.Ready
    width: content.width + (d.style ? d.style.padding.left + d.style.padding.right : 0)
    height: content.height + (d.style ? d.style.padding.top + d.style.padding.bottom : 0)

    Loader {
        id: styleLoader
        active: !__menu.isNative
        sourceComponent: __menu.style
        property alias __control: menuFrameLoader
        onStatusChanged: {
            if (status === Loader.Error)
                console.error("Failed to load Style for", __menu)
        }
    }
    sourceComponent: d.style ? d.style.frame : undefined

    QtObject {
        id: d
        property var mnemonicsMap: ({})
        readonly property Style style: styleLoader.item
        readonly property Component menuItemPanel: style ? style.menuItemPanel : null

        function canBeHovered(index) {
            var item = content.menuItemAt(index)
            if (item && item.visible && item.styleData.type !== MenuItemType.Separator && item.styleData.enabled) {
                __menu.__currentIndex = index
                return true
            }
            return false
        }

        function triggerCurrent() {
            var item = content.menuItemAt(__menu.__currentIndex)
            if (item)
                content.triggered(item)
        }

        function triggerAndDismiss(item) {
            if (item && item.styleData.type !== MenuItemType.Separator) {
                __menu.__dismissMenu()
                if (item.styleData.type !== MenuItemType.Menu)
                    item.__menuItem.trigger()
                __menu.__destroyAllMenuPopups()
            }
        }
    }

    focus: true

    Keys.onPressed: {
        var item = null
        if (!(event.modifiers & Qt.AltModifier)
                && (item = d.mnemonicsMap[event.text.toUpperCase()])) {
            if (item.styleData.type === MenuItemType.Menu) {
                __menu.__currentIndex = item.__menuItemIndex
                item.__showSubMenu(true)
                item.__menuItem.__currentIndex = 0
            } else {
                d.triggerAndDismiss(item)
            }
            event.accepted = true
        } else {
            event.accepted = false
        }
    }

    Keys.onEscapePressed: __menu.__dismissMenu()

    Keys.onDownPressed: {
        if (__menu.__currentIndex < 0)
            __menu.__currentIndex = -1

        for (var i = __menu.__currentIndex + 1;
             i < __menu.items.length && !d.canBeHovered(i); i++)
            ;
        event.accepted = true
    }

    Keys.onUpPressed: {
        for (var i = __menu.__currentIndex - 1;
             i >= 0 && !d.canBeHovered(i); i--)
            ;
        event.accepted = true
    }

    Keys.onLeftPressed: {
        if ((event.accepted = __menu.__parentMenu.hasOwnProperty("title"))) {
            __menu.__closeMenu()
            __menu.__destroyMenuPopup()
        }
    }

    Keys.onRightPressed: {
        var item = content.menuItemAt(__menu.__currentIndex)
        if ((event.accepted = (item && item.styleData.type === MenuItemType.Menu))) {
            item.__showSubMenu(true)
            item.__menuItem.__currentIndex = 0
        }
    }

    Keys.onSpacePressed: d.triggerCurrent()
    Keys.onReturnPressed: d.triggerCurrent()
    Keys.onEnterPressed: d.triggerCurrent()

    Binding {
        // Make sure the styled frame is in the background
        target: item
        property: "z"
        value: content.z - 1
    }

    ColumnMenuContent {
        id: content
        x: d.style ? d.style.padding.left : 0
        y: d.style ? d.style.padding.top : 0
        menuItemDelegate: menuItemComponent
        scrollIndicatorStyle: d.style && d.style.scrollIndicator || null
        scrollerStyle: d.style && d.style.__scrollerStyle
        itemsModel: __menu.items
        minWidth: __menu.__minimumWidth
        maxHeight: d.style ? d.style.__maxPopupHeight : 0
        onTriggered: if (item.__menuItem.enabled) d.triggerAndDismiss(item)
    }

    Component {
        id: menuItemComponent
        Loader {
            id: menuItemLoader

            property QtObject styleData: QtObject {
                id: opts
                readonly property int index: __menuItemIndex
                readonly property int type: __menuItem ? __menuItem.type : -1
                readonly property bool selected: type !== MenuItemType.Separator && __menu.__currentIndex === index
                readonly property bool pressed: type !== MenuItemType.Separator && __menu.__currentIndex === index
                                                && content.mousePressed // TODO Add key pressed condition once we get delayed menu closing
                readonly property string text: type === MenuItemType.Menu ? __menuItem.title :
                                               type !== MenuItemType.Separator ? __menuItem.text : ""
                readonly property bool underlineMnemonic: __menu.__contentItem.altPressed
                readonly property string shortcut: !!__menuItem && __menuItem["shortcut"] || ""
                readonly property var iconSource: !!__menuItem && __menuItem["iconSource"] || undefined
                readonly property bool enabled: type !== MenuItemType.Separator && !!__menuItem && __menuItem.enabled
                readonly property bool checked: !!__menuItem && !!__menuItem["checked"]
                readonly property bool checkable: !!__menuItem && !!__menuItem["checkable"]
                readonly property bool exclusive: !!__menuItem && !!__menuItem["exclusiveGroup"]
                readonly property int scrollerDirection: Qt.NoArrow
            }

            readonly property var __menuItem: modelData
            readonly property int __menuItemIndex: index

            sourceComponent: d.menuItemPanel
            enabled: visible && opts.enabled
            visible: !!__menuItem && __menuItem.visible
            active: visible

            function __showSubMenu(immediately) {
                if (!__menuItem.enabled)
                    return;
                if (immediately) {
                    if (__menu.__currentIndex === __menuItemIndex) {
                        if (__menuItem.__usingDefaultStyle)
                            __menuItem.style = __menu.style
                        __menuItem.__popup(Qt.rect(menuFrameLoader.width - (d.style.submenuOverlap + d.style.padding.right), -d.style.padding.top, 0, 0), -1)
                    }
                } else {
                    openMenuTimer.start()
                }
            }

            Timer {
                id: openMenuTimer
                interval: d.style.submenuPopupDelay
                onTriggered: menuItemLoader.__showSubMenu(true)
            }

            function __closeSubMenu() {
                if (openMenuTimer.running)
                    openMenuTimer.stop()
                else if (__menuItem.__popupVisible)
                    closeMenuTimer.start()
            }

            Timer {
                id: closeMenuTimer
                interval: 1
                onTriggered: {
                    if (__menu.__currentIndex !== __menuItemIndex) {
                        __menuItem.__closeMenu()
                        __menuItem.__destroyMenuPopup()
                    }
                }
            }

            onLoaded: {
                __menuItem.__visualItem = menuItemLoader

                if (content.width < item.implicitWidth)
                    content.width = item.implicitWidth

                var title = opts.text
                var ampersandPos = title.indexOf("&")
                if (ampersandPos !== -1)
                    d.mnemonicsMap[title[ampersandPos + 1].toUpperCase()] = menuItemLoader
            }

            Binding {
                target: menuItemLoader.item
                property: "width"
                property alias menuItem: menuItemLoader.item
                value: menuItem ? Math.max(__menu.__minimumWidth, content.width) - 2 * menuItem.x : 0
            }
        }
    }
}
