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
import QtQuick.Layouts 1.0

/*!
    \qmltype GroupBox
    \inqmlmodule QtQuick.Controls
    \since 5.1
    \ingroup controls
    \brief GroupBox provides a group box frame with a title.

    \image groupbox.png

    A group box provides a frame, a title on top and displays various other controls inside itself. Group boxes can also be checkable.

    Child controls in checkable group boxes are enabled or disabled depending on whether or not the group box is checked.

    You can minimize the space consumption of a group box by enabling the flat property.
    In most styles, enabling this property results in the removal of the left, right and bottom edges of the frame.

    To add content to a group box, you can reparent it to its contentItem property.

    The implicit size of the GroupBox is calculated based on the size of its content. If you want to anchor
    items inside the group box, you must specify an explicit width and height on the GroupBox itself.

    The following example shows how we use a GroupBox:

    \qml
    GroupBox {
        title: "Joining for?"

        Column {
            spacing: 10

            CheckBox {
                text: "Breakfast"
                checked: true
            }
            CheckBox {
                text: "Lunch"
                checked: false
            }
            CheckBox {
                text: "Dinner"
                checked: true
            }
        }
    }
    \endqml

    \sa CheckBox, RadioButton, Layout

*/

FocusScope {
    id: groupbox

    /*!
        This property holds the group box title text.

        There is no default title text.
    */
    property string title

    /*!
        This property holds whether the group box is painted flat or has a frame.

        A group box usually consists of a surrounding frame with a title at the top.
        If this property is enabled, only the top part of the frame is drawn in most styles;
        otherwise, the whole frame is drawn.

        By default, this property is disabled, so group boxes are not flat unless explicitly specified.

        \note In some styles, flat and non-flat group boxes have similar representations and may not be as
              distinguishable as they are in other styles.
    */
    property bool flat: false

    /*!
        This property holds whether the group box has a checkbox in its title.

        If this property is true, the group box displays its title using a checkbox in place of an ordinary label.
        If the checkbox is checked, the group box's children are enabled; otherwise, they are disabled and inaccessible.

        By default, group boxes are not checkable.
    */
    property bool checkable: false

    /*!
        \qmlproperty bool GroupBox::checked

        This property holds whether the group box is checked.

        If the group box is checkable, it is displayed with a check box. If the check box is checked, the group
        box's children are enabled; otherwise, the children are disabled and are inaccessible to the user.

        By default, checkable group boxes are also checked.
    */
    property alias checked: check.checked


    /*! \internal */
    default property alias __content: container.data

    /*!
        \qmlproperty Item GroupBox::contentItem

        This property holds the content Item of the group box.

        Items declared as children of a GroupBox are automatically parented to the GroupBox's contentItem.
        Items created dynamically need to be explicitly parented to the contentItem:

        \note The implicit size of the GroupBox is calculated based on the size of its content. If you want to anchor
        items inside the group box, you must specify an explicit width and height on the GroupBox itself.
    */
    readonly property alias contentItem: container

    /*! \internal */
    property Component style: Qt.createComponent(Settings.style + "/GroupBoxStyle.qml", groupbox)

    /*! \internal */
    property alias __checkbox: check

    /*! \internal */
    property alias __style: styleLoader.item

    implicitWidth: Math.max((!anchors.fill ? container.calcWidth() : 0) + loader.leftMargin + loader.rightMargin,
                            sizeHint.implicitWidth + (checkable ? 24 : 6))
    implicitHeight: (!anchors.fill ? container.calcHeight() : 0) + loader.topMargin + loader.bottomMargin

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight

    Accessible.role: Accessible.Grouping
    Accessible.name: title

    activeFocusOnTab: false


    data: [
        Loader {
            id: loader
            anchors.fill: parent
            property int topMargin: __style ? __style.padding.top : 0
            property int bottomMargin: __style ? __style.padding.bottom : 0
            property int leftMargin: __style ? __style.padding.left : 0
            property int rightMargin: __style ? __style.padding.right : 0
            sourceComponent: styleLoader.item ? styleLoader.item.panel : null
            onLoaded: item.z = -1
            Text { id: sizeHint ; visible: false ; text: title }
            Loader {
                id: styleLoader
                property alias __control: groupbox
                sourceComponent: groupbox.style
            }
        },
        CheckBox {
            id: check
            objectName: "check"
            checked: true
            text: groupbox.title
            visible: checkable
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: loader.topMargin
            activeFocusOnTab: groupbox.checkable
            style: CheckBoxStyle { panel: Item{} }
        },
        Item {
            id: container
            objectName: "container"
            z: 1
            focus: true
            anchors.fill: parent

            anchors.topMargin: loader.topMargin
            anchors.leftMargin: loader.leftMargin
            anchors.rightMargin: loader.rightMargin
            anchors.bottomMargin: loader.bottomMargin
            enabled: (!groupbox.checkable || groupbox.checked)

            property Item layoutItem: container.children.length === 1 ? container.children[0] : null
            function calcWidth () { return (layoutItem ? (layoutItem.implicitWidth || layoutItem.width) +
                                                         (layoutItem.anchors.fill ? layoutItem.anchors.leftMargin +
                                                                                    layoutItem.anchors.rightMargin : 0) : container.childrenRect.width) }
            function calcHeight () { return (layoutItem ? (layoutItem.implicitHeight || layoutItem.height) +
                                                          (layoutItem.anchors.fill ? layoutItem.anchors.topMargin +
                                                                                     layoutItem.anchors.bottomMargin : 0) : container.childrenRect.height) }
        }]
}
