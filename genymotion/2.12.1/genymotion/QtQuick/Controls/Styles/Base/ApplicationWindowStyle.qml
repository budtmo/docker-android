/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
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
    \qmltype ApplicationWindowStyle
    \inqmlmodule QtQuick.Controls.Styles
    \since 5.4
    \ingroup controlsstyling
    \brief Provides custom styling for ApplicationWindow

    You can create a custom window background by replacing the "background"
    delegate of ApplicationWindowStyle with a custom design.

    Example:
    \qml
    ApplicationWindow {
        style: ApplicationWindowStyle {
            background: BorderImage {
                source: "background.png"
                border { left: 20; top: 20; right: 20; bottom: 20 }
            }
        }
    }
    \endqml
*/
QtObject {
    /*! The window attached to this style. */
    readonly property ApplicationWindow control: __control

    /*! A custom background for the window.

        \note The window might have a custom background color set. The custom
              background color is automatically filled by the window. The background
              delegate should respect the custom background color by either hiding
              itself altogether when a custom background color is set, or by letting
              the custom background color shine through.

        The following read-only property is available within the scope
        of the background delegate:
        \table
            \row \li \b {styleData.hasColor} : bool \li Whether the window has a custom background color set.
        \endtable
    */
    property Component background: Rectangle {
        visible: !styleData.hasColor
        color: SystemPaletteSingleton.window(true)
    }

    /*! \internal */
    property Component panel: Item {
        readonly property alias contentArea: contentArea
        readonly property alias menuBarArea: menuBarArea
        readonly property alias toolBarArea: toolBarArea
        readonly property alias statusBarArea: statusBarArea

        Loader {
            anchors.fill: parent
            sourceComponent: background
        }

        Item {
            id: contentArea
            anchors.top: toolBarArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: statusBarArea.top
        }

        Item {
            id: toolBarArea
            anchors.top: parent.menuBarArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: childrenRect.height
            height: visibleChildren.length > 0 ? implicitHeight: 0
        }

        Item {
            id: menuBarArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: childrenRect.height
            height: visibleChildren.length > 0 ? implicitHeight: 0
        }

        Item {
            id: statusBarArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: childrenRect.height
            height: visibleChildren.length > 0 ? implicitHeight: 0
        }
    }
}
