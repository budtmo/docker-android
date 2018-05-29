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
import "." as Desktop

Style {
    readonly property ComboBox control: __control
    property int renderType: Text.NativeRendering
    padding { top: 4 ; left: 6 ; right: 6 ; bottom:4 }
    property Component panel: Item {
        property bool popup: !!styleItem.styleHint("comboboxpopup")
        property color textColor: SystemPaletteSingleton.text(control.enabled)
        property color selectionColor: SystemPaletteSingleton.highlight(control.enabled)
        property color selectedTextColor: SystemPaletteSingleton.highlightedText(control.enabled)
        property int dropDownButtonWidth: 24

        implicitWidth: 125
        implicitHeight: styleItem.implicitHeight
        baselineOffset: styleItem.baselineOffset
        anchors.fill: parent
        StyleItem {
            id: styleItem

            height: parent.height
            width: parent.width
            elementType: "combobox"
            sunken: control.pressed
            raised: !sunken
            hover: control.hovered
            enabled: control.enabled
            // The style makes sure the text rendering won't overlap the decoration.
            // In that case, 35 pixels margin in this case looks good enough. Worst
            // case, the ellipsis will be truncated (2nd worst, not visible at all).
            text: elidedText(control.currentText, Text.ElideRight, parent.width - 35)
            hasFocus: control.activeFocus
            // contentHeight as in QComboBox
            contentHeight: Math.max(Math.ceil(textHeight("")), 14) + 2

            hints: control.styleHints
            properties: {
                "popup": control.__popup,
                "editable" : control.editable
            }
        }
    }

    property Component __popupStyle: MenuStyle {
        __menuItemType: "comboboxitem"
    }

    property Component __dropDownStyle: Style {
        id: dropDownStyleRoot
        property int __maxPopupHeight: 600
        property int submenuOverlap: 0
        property int submenuPopupDelay: 0

        property Component frame: StyleItem {
            elementType: "frame"
            Component.onCompleted: {
                var defaultFrameWidth = pixelMetric("defaultframewidth")
                dropDownStyleRoot.padding.left = defaultFrameWidth
                dropDownStyleRoot.padding.right = defaultFrameWidth
                dropDownStyleRoot.padding.top = defaultFrameWidth
                dropDownStyleRoot.padding.bottom = defaultFrameWidth
            }
        }

        property Component menuItemPanel: StyleItem {
            elementType: "itemrow"
            selected: styleData.selected

            implicitWidth: textItem.implicitWidth
            implicitHeight: textItem.implicitHeight

            StyleItem {
                id: textItem
                elementType: "item"
                contentWidth: textWidth(text)
                contentHeight: textHeight(text)
                text: styleData.text
                selected: parent ? parent.selected : false
            }
        }

        property Component __scrollerStyle: Desktop.ScrollViewStyle { }
    }
}
