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
    \qmltype ProgressBarStyle

    \inqmlmodule QtQuick.Controls.Styles
    \since 5.1
    \ingroup controlsstyling
    \brief Provides custom styling for ProgressBar

    Example:
    \qml
    ProgressBar {
        value: slider.value
        style: ProgressBarStyle {
            background: Rectangle {
                radius: 2
                color: "lightgray"
                border.color: "gray"
                border.width: 1
                implicitWidth: 200
                implicitHeight: 24
            }
            progress: Rectangle {
                color: "lightsteelblue"
                border.color: "steelblue"
            }
        }
    }
    \endqml

    Note that the example above is somewhat simplified and will not animate
    an indeterminate progress bar. The following snippet demonstrates
    how you can incorporate a custom animation for the indeterminate
    state as well.

    \code
    progress: Rectangle {
        border.color: "steelblue"
        color: "lightsteelblue"

        // Indeterminate animation by animating alternating stripes:
        Item {
            anchors.fill: parent
            anchors.margins: 1
            visible: control.indeterminate
            clip: true
            Row {
                Repeater {
                    Rectangle {
                        color: index % 2 ? "steelblue" : "lightsteelblue"
                        width: 20 ; height: control.height
                    }
                    model: control.width / 20 + 2
                }
                XAnimator on x {
                    from: 0 ; to: -40
                    loops: Animation.Infinite
                    running: control.indeterminate
                }
            }
        }
    }
    \endcode


*/

Style {
    id: progressBarStyle

    /*! The \l ProgressBar this style is attached to. */
    readonly property ProgressBar control: __control

    /*! A value in the range [0-1] indicating the current progress. */
    readonly property real currentProgress: control.indeterminate ? 1.0 :
                                                                    control.value / control.maximumValue

    /*! This property holds the visible contents of the progress bar
        You can access the Slider through the \c control property.

        For convenience, you can also access the readonly property \c styleData.progress
        which provides the current progress as a \c real in the range [0-1]
    */
    padding { top: 0 ; left: 0 ; right: 0 ; bottom: 0 }

    /*! \qmlproperty Component ProgressBarStyle::progress
        The progress component for this style.
    */
    property Component progress: Item {
        property color progressColor: "#49d"
        anchors.fill: parent
        clip: true
        Rectangle {
            id: base
            width: control.width
            height: control.height
            radius: TextSingleton.implicitHeight * 0.16
            antialiasing: true
            gradient: Gradient {
                GradientStop {color: Qt.lighter(progressColor, 1.3)  ; position: 0}
                GradientStop {color: progressColor ; position: 1.4}
            }
            border.width: 1
            border.color: Qt.darker(progressColor, 1.2)
            Rectangle {
                color: "transparent"
                radius: 1.5
                clip: true
                antialiasing: true
                anchors.fill: parent
                anchors.margins: 1
                border.color: Qt.rgba(1,1,1,0.1)
                Image {
                    visible: control.indeterminate
                    height: parent.height
                    NumberAnimation on x {
                        from: -39
                        to: 0
                        running: control.indeterminate
                        duration: 800
                        loops: Animation.Infinite
                    }
                    fillMode: Image.Tile
                    width: parent.width + 25
                    source: "images/progress-indeterminate.png"
                }
            }
        }
        Rectangle {
            height: parent.height - 2
            width: 1
            y: 1
            anchors.right: parent.right
            anchors.rightMargin: 1
            color:  Qt.rgba(1,1,1,0.1)
            visible: splitter.visible
        }
        Rectangle {
            id: splitter
            height: parent.height - 2
            width: 1
            y: 1
            anchors.right: parent.right
            color: Qt.darker(progressColor, 1.2)
            property int offset: currentProgress * control.width
            visible: offset > base.radius && offset < control.width - base.radius + 1
        }
    }

    /*! \qmlproperty Component ProgressBarStyle::background
        The background component for this style.

        \note The implicitWidth and implicitHeight of the background component
        must be set.
    */
    property Component background: Item {
        implicitWidth: 200
        implicitHeight: Math.max(17, Math.round(TextSingleton.implicitHeight * 0.7))
        Rectangle {
            anchors.fill: parent
            anchors.bottomMargin: control.pressed ? 0 : -1
            color: "#44ffffff"
            radius: baserect.radius
        }
        Rectangle {
            id: baserect
            gradient: Gradient {
                GradientStop {color: "#eee" ; position: 0}
                GradientStop {color: "#fff" ; position: 0.1}
                GradientStop {color: "#fff" ; position: 1}
            }
            radius: TextSingleton.implicitHeight * 0.16
            anchors.fill: parent
            border.color: control.activeFocus ? "#47b" : "#999"
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: control.activeFocus ? "#47b" : "white"
                opacity: control.hovered || control.activeFocus ? 0.1 : 0
                Behavior on opacity {NumberAnimation{ duration: 100 }}
            }
        }
    }

    /*! \qmlproperty Component ProgressBarStyle::panel
        The panel component for this style.
    */
    property Component panel: Item{
        property bool horizontal: control.orientation == Qt.Horizontal
        implicitWidth: horizontal ? backgroundLoader.implicitWidth : backgroundLoader.implicitHeight
        implicitHeight: horizontal ? backgroundLoader.implicitHeight : backgroundLoader.implicitWidth

        Item {
            width: horizontal ? parent.width : parent.height
            height: !horizontal ? parent.width : parent.height
            y: horizontal ? 0 : width
            rotation: horizontal ? 0 : -90
            transformOrigin: Item.TopLeft

            Loader {
                id: backgroundLoader
                anchors.fill: parent
                sourceComponent: background
            }

            Loader {
                sourceComponent: progressBarStyle.progress
                anchors.topMargin: padding.top
                anchors.leftMargin: padding.left
                anchors.rightMargin: padding.right
                anchors.bottomMargin: padding.bottom

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: currentProgress * (parent.width - padding.left - padding.right)
            }
        }
    }
}
