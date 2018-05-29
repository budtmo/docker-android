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
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import QtQuick.Controls.Private 1.0

/*!
    \qmltype CheckBoxStyle
    \inqmlmodule QtQuick.Controls.Styles
    \since 5.1
    \ingroup controlsstyling
    \brief Provides custom styling for CheckBox

    Example:
    \qml
    CheckBox {
        text: "Check Box"
        style: CheckBoxStyle {
            indicator: Rectangle {
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 3
                    border.color: control.activeFocus ? "darkblue" : "gray"
                    border.width: 1
                    Rectangle {
                        visible: control.checked
                        color: "#555"
                        border.color: "#333"
                        radius: 1
                        anchors.margins: 4
                        anchors.fill: parent
                    }
            }
        }
    }
    \endqml
*/
Style {
    id: checkboxStyle

    /*! The \l CheckBox this style is attached to. */
    readonly property CheckBox control: __control

    /*! This defines the text label. */
    property Component label: Item {
        implicitWidth: text.implicitWidth + 2
        implicitHeight: text.implicitHeight
        baselineOffset: text.baselineOffset
        Rectangle {
            anchors.fill: text
            anchors.margins: -1
            anchors.leftMargin: -3
            anchors.rightMargin: -3
            visible: control.activeFocus
            height: 6
            radius: 3
            color: "#224f9fef"
            border.color: "#47b"
            opacity: 0.6
        }
        Text {
            id: text
            text: StyleHelpers.stylizeMnemonics(control.text)
            anchors.centerIn: parent
            color: SystemPaletteSingleton.text(control.enabled)
            renderType: Settings.isMobile ? Text.QtRendering : Text.NativeRendering
        }
    }
    /*! The background under indicator and label. */
    property Component background

    /*! The spacing between indicator and label. */
    property int spacing: Math.round(TextSingleton.implicitHeight/4)

    /*! This defines the indicator button. */
    property Component indicator:  Item {
        implicitWidth: Math.round(TextSingleton.implicitHeight)
        height: width
        Rectangle {
            anchors.fill: parent
            anchors.bottomMargin: -1
            color: "#44ffffff"
            radius: baserect.radius
        }
        Rectangle {
            id: baserect
            gradient: Gradient {
                GradientStop {color: "#eee" ; position: 0}
                GradientStop {color: control.pressed ? "#eee" : "#fff" ; position: 0.1}
                GradientStop {color: "#fff" ; position: 1}
            }
            radius: TextSingleton.implicitHeight * 0.16
            anchors.fill: parent
            border.color: control.activeFocus ? "#47b" : "#999"
        }

        Image {
            source: "images/check.png"
            opacity: control.checkedState === Qt.Checked ? control.enabled ? 1 : 0.5 : 0
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 1
            Behavior on opacity {NumberAnimation {duration: 80}}
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: Math.round(baserect.radius)
            antialiasing: true
            gradient: Gradient {
                GradientStop {color: control.pressed ? "#555" : "#999" ; position: 0}
                GradientStop {color: "#555" ; position: 1}
            }
            radius: baserect.radius - 1
            anchors.centerIn: parent
            anchors.alignWhenCentered: true
            border.color: "#222"
            Behavior on opacity {NumberAnimation {duration: 80}}
            opacity: control.checkedState === Qt.PartiallyChecked ? control.enabled ? 1 : 0.5 : 0
        }
    }

    /*! \internal */
    property Component panel: Item {
        implicitWidth: Math.max(backgroundLoader.implicitWidth, row.implicitWidth + padding.left + padding.right)
        implicitHeight: Math.max(backgroundLoader.implicitHeight, labelLoader.implicitHeight + padding.top + padding.bottom,indicatorLoader.implicitHeight + padding.top + padding.bottom)
        baselineOffset: labelLoader.item ? padding.top + labelLoader.item.baselineOffset : 0

        Loader {
            id: backgroundLoader
            sourceComponent: background
            anchors.fill: parent
        }
        RowLayout {
            id: row
            anchors.fill: parent

            anchors.leftMargin: padding.left
            anchors.rightMargin: padding.right
            anchors.topMargin: padding.top
            anchors.bottomMargin: padding.bottom

            spacing: checkboxStyle.spacing
            Loader {
                id: indicatorLoader
                sourceComponent: indicator
                anchors.verticalCenter: parent.verticalCenter
            }
            Loader {
                id: labelLoader
                Layout.fillWidth: true
                sourceComponent: label
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
