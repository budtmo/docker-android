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
    \qmltype ToolBarStyle
    \inqmlmodule QtQuick.Controls.Styles
    \ingroup controlsstyling
    \since 5.2
    \brief Provides custom styling for ToolBar

    The tool bar can be defined by overriding the background component and
    setting the content padding.

    Example:
    \qml
    ToolBar {
        style: ToolBarStyle {
            padding {
                left: 8
                right: 8
                top: 3
                bottom: 3
            }
            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                border.color: "#999"
                gradient: Gradient {
                    GradientStop { position: 0 ; color: "#fff" }
                    GradientStop { position: 1 ; color: "#eee" }
                }
            }
        }
    }
    \endqml
*/

Style {

    /*! The content padding inside the tool bar. */
    padding {
        left: 6
        right: 6
        top: 3
        bottom: 3
    }

    /*! This defines the background of the tool bar. */
    property Component background: Item {
        implicitHeight: 40
        implicitWidth: 200
        Rectangle {
            anchors.fill: parent
            gradient: Gradient{
                GradientStop{color: "#eee" ; position: 0}
                GradientStop{color: "#ccc" ; position: 1}
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#999"
            }
        }
    }

    /*! This defines the menu button appearance on platforms
        that have a unified tool bar and menu bar.

        \since QtQuick.Controls.Styles 1.3

        The following read-only properties are available within the scope
        of the menu button delegate:
        \table
            \row \li \b {styleData.pressed} : bool \li Whether the button is pressed.
            \row \li \b {styleData.hovered} : bool \li Whether the button is hovered.
            \row \li \b {styleData.activeFocus} : bool \li Whether the button has active focus.
        \endtable
    */
    property Component menuButton: null

    property Component panel: Loader {
        sourceComponent: background
    }
}
