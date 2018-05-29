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
    \qmltype BusyIndicatorStyle
    \inqmlmodule QtQuick.Controls.Styles
    \since 5.2
    \ingroup controlsstyling
    \brief Provides custom styling for BusyIndicatorStyle

    You can create a busy indicator by replacing the "indicator" delegate
    of the BusyIndicatorStyle with a custom design.

    Example:
    \qml
    BusyIndicator {
        style: BusyIndicatorStyle {
            indicator: Image {
                visible: control.running
                source: "spinner.png"
                RotationAnimator on rotation {
                    running: control.running
                    loops: Animation.Infinite
                    duration: 2000
                    from: 0 ; to: 360
                }
            }
        }
    }
    \endqml
*/
Style {
    id: indicatorstyle

    /*! The \l BusyIndicator this style is attached to. */
    readonly property BusyIndicator control: __control

    /*! This defines the appearance of the busy indicator. */
    property Component indicator: Item {
        id: indicatorItem

        implicitWidth: 48
        implicitHeight: 48

        opacity: control.running ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 250 } }

        Image {
            anchors.centerIn: parent
            anchors.alignWhenCentered: true
            width: Math.min(parent.width, parent.height)
            height: width
            source: width <= 32 ? "images/spinner_small.png" :
                                  width >= 48 ? "images/spinner_large.png" :
                                                "images/spinner_medium.png"
            RotationAnimator on rotation {
                duration: 800
                loops: Animation.Infinite
                from: 0
                to: 360
                running: indicatorItem.visible && (control.running || indicatorItem.opacity > 0);
            }
        }
    }

    /*! \internal */
    property Component panel: Item {
        anchors.fill: parent
        implicitWidth: indicatorLoader.implicitWidth
        implicitHeight: indicatorLoader.implicitHeight

        Loader {
            id: indicatorLoader
            sourceComponent: indicator
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width
        }
    }
}
