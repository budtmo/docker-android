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
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Private 1.0

Style {
    id: styleRoot

    property string __menuItemType: "menuitem"

    property int submenuOverlap: 0
    property int submenuPopupDelay: 0
    property int __maxPopupHeight: 0

    property Component frame: StyleItem {
        elementType: "menu"

        Rectangle {
            visible: anchors.margins > 0
            anchors {
                fill: parent
                margins: pixelMetric("menupanelwidth")
            }
            color: SystemPaletteSingleton.window(control.enabled)
        }

        Accessible.role: Accessible.PopupMenu

        Component.onCompleted: {
            var menuHMargin = pixelMetric("menuhmargin")
            var menuVMargin = pixelMetric("menuvmargin")
            var menuPanelWidth = pixelMetric("menupanelwidth")
            styleRoot.padding.left = menuHMargin + menuPanelWidth
            styleRoot.padding.right = menuHMargin + menuPanelWidth
            styleRoot.padding.top = menuVMargin + menuPanelWidth
            styleRoot.padding.bottom = menuVMargin + menuPanelWidth
            styleRoot.submenuOverlap = 2 * menuPanelWidth
            styleRoot.submenuPopupDelay = styleHint("submenupopupdelay")
        }

        // ### The Screen attached property can only be set on an Item,
        // ### and will get its values only when put on a Window.
        readonly property int desktopAvailableHeight: Screen.desktopAvailableHeight
        Binding {
            target: styleRoot
            property: "__maxPopupHeight"
            value: desktopAvailableHeight * 0.99
        }
    }

    property Component menuItemPanel: StyleItem {
        elementType: __menuItemType

        text: styleData.text
        property string textAndShorcut: text + (styleData.shortcut ? "\t" + styleData.shortcut : "")
        contentWidth: textWidth(textAndShorcut)
        contentHeight: textHeight(textAndShorcut)

        enabled: styleData.enabled
        selected: styleData.selected
        on: styleData.checkable && styleData.checked

        hints: { "showUnderlined": styleData.underlineMnemonic }

        properties: {
            "checkable": styleData.checkable,
            "exclusive": styleData.exclusive,
            "shortcut": styleData.shortcut,
            "type": styleData.type,
            "scrollerDirection": styleData.scrollerDirection,
            "icon": !!__menuItem && __menuItem.__icon
        }

        Accessible.role: Accessible.MenuItem
        Accessible.name: StyleHelpers.removeMnemonics(text)
    }

    property Component scrollIndicator: menuItemPanel

    property Component __scrollerStyle: null
}
