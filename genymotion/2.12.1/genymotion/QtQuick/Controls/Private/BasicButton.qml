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

/*!
    \qmltype BasicButton
    \internal
    \qmlabstract
    \inqmlmodule QtQuick.Controls.Private
*/

Control {
    id: button

    /*! This signal is emitted when the button is clicked. */
    signal clicked

    /*! \qmlproperty bool BasicButton::pressed

        This property holds whether the button is being pressed. */
    readonly property alias pressed: button.__effectivePressed

    /*! \qmlproperty bool BasicButton::hovered

        This property indicates whether the control is being hovered.
    */
    readonly property alias hovered: behavior.containsMouse

    /*! This property holds whether the button is checkable.

        The default value is \c false. */
    property bool checkable: false
    Accessible.checkable: checkable

    /*! This property holds whether the button is checked.

        Only checkable buttons can be checked.

        The default value is \c false. */
    property bool checked: false
    Accessible.checked: checked

    /*! This property holds the ExclusiveGroup that the button belongs to.

        The default value is \c null. */
    property ExclusiveGroup exclusiveGroup: null

    /*! This property holds the associated button action.

        If a button has an action associated, the action defines the
        button's properties like checked, text, tooltip etc.

        When an action is set, it's still possible to override the \l text,
        \l tooltip, \l iconSource, and \l iconName properties.

        The default value is \c null. */
    property Action action: null

    /*! This property specifies whether the button should gain active focus when pressed.

        The default value is \c false. */
    property bool activeFocusOnPress: false

    /*! This property holds the text shown on the button. If the button has no
        text, the \l text property will be an empty string.

        The default value is the empty string.
    */
    property string text: action ? action.text : ""

    /*! This property holds the button tooltip. */
    property string tooltip: action ? (action.tooltip || StyleHelpers.removeMnemonics(action.text)) : ""

    /*! This property holds the icon shown on the button. If the button has no
        icon, the iconSource property will be an empty string.

        The default value is the empty string.
    */
    property url iconSource: action ? action.iconSource : ""

    /*! The image label source as theme name.
        When an icon from the platform icon theme is found, this takes
        precedence over iconSource.
    */
    property string iconName: action ? action.iconName : ""

    /*! \internal */
    property string __position: "only"
    /*! \internal */
    readonly property bool __iconOverriden: button.action && (button.action.iconSource !== button.iconSource || button.action.iconName !== button.iconName)
    /*! \internal */
    property Action __action: action || ownAction
    /*! \internal */
    readonly property Action __iconAction: __iconOverriden ? ownAction : __action

    /*! \internal */
    onExclusiveGroupChanged: {
        if (exclusiveGroup)
            exclusiveGroup.bindCheckable(button)
    }

    Accessible.role: Accessible.Button
    Accessible.description: tooltip

    /*! \internal */
    function accessiblePressAction() {
        __action.trigger(button)
    }

    Action {
        id: ownAction
        iconSource: !button.action || __iconOverriden ? button.iconSource : ""
        iconName: !button.action || __iconOverriden ? button.iconName : ""

        // let ownAction handle mnemonic if and only if the button does
        // not already have an action assigned to avoid ambiguous shortcuts
        text: button.action ? "" : button.text
    }

    Connections {
        target: __action
        onTriggered: button.clicked()
    }

    activeFocusOnTab: true

    Keys.onPressed: {
        if (event.key === Qt.Key_Space && !event.isAutoRepeat && !behavior.pressed)
            behavior.keyPressed = true;
    }

    onFocusChanged: if (!focus) behavior.keyPressed = false

    Keys.onReleased: {
        if (event.key === Qt.Key_Space && !event.isAutoRepeat && behavior.keyPressed) {
            behavior.keyPressed = false;
            __action.trigger(button)
            behavior.toggle()
        }
    }

    MouseArea {
        id: behavior
        property bool keyPressed: false
        property bool effectivePressed: pressed && containsMouse || keyPressed

        anchors.fill: parent
        hoverEnabled: Settings.hoverEnabled
        enabled: !keyPressed

        function toggle() {
            if (button.checkable && !button.action && !(button.checked && button.exclusiveGroup))
                button.checked = !button.checked
        }

        onReleased: {
            if (containsMouse) {
                toggle()
                __action.trigger(button)
            }
        }
        onExited: Tooltip.hideText()
        onCanceled: Tooltip.hideText()
        onPressed: {
            if (activeFocusOnPress)
                button.forceActiveFocus()
        }

        Timer {
            interval: 1000
            running: behavior.containsMouse && !pressed && tooltip.length
            onTriggered: Tooltip.showText(behavior, Qt.point(behavior.mouseX, behavior.mouseY), tooltip)
        }
    }

    /*! \internal */
    property var __behavior: behavior

    /*! \internal */
    property bool __effectivePressed: behavior.effectivePressed

    states: [
        State {
            name: "boundAction"
            when: action !== null
            PropertyChanges {
                target: button
                enabled: action.enabled
                checkable: action.checkable
                checked: action.checked
            }
        }
    ]
}
