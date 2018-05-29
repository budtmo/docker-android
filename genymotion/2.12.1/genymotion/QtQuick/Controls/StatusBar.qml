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
    \qmltype StatusBar
    \inqmlmodule QtQuick.Controls
    \since 5.1
    \ingroup applicationwindow
    \brief Contains status information in your app.

    The common way of using StatusBar is in relation to \l ApplicationWindow.

    Note that the StatusBar does not provide a layout of its own, but requires
    you to position its contents, for instance by creating a \l RowLayout.

    If only a single item is used within the StatusBar, it will resize to fit the implicitHeight
    of its contained item. This makes it particularly suitable for use together with layouts.
    Otherwise the height is platform dependent.

    \code
    import QtQuick.Controls 1.2
    import QtQuick.Layouts 1.0

    ApplicationWindow {
        statusBar: StatusBar {
            RowLayout {
                anchors.fill: parent
                Label { text: "Read Only" }
            }
        }
    }
    \endcode
*/

FocusScope {
    id: statusbar

    activeFocusOnTab: false
    Accessible.role: Accessible.StatusBar

    width: parent ? parent.width : implicitWidth
    implicitWidth: container.leftMargin + container.rightMargin
                   + Math.max(container.layoutWidth, __panel ? __panel.implicitWidth : 0)
    implicitHeight: container.topMargin + container.bottomMargin
                    + Math.max(container.layoutHeight, __panel ? __panel.implicitHeight : 0)

    /*! \internal */
    property Component style: Qt.createComponent(Settings.style + "/StatusBarStyle.qml", statusbar)

    /*! \internal */
    property alias __style: styleLoader.item

    /*! \internal */
    property Item __panel: panelLoader.item

    /*! \internal */
    default property alias __content: container.data

    /*!
        \qmlproperty Item StatusBar::contentItem

        This property holds the content Item of the status bar.

        Items declared as children of a StatusBar are automatically parented to the StatusBar's contentItem.
        Items created dynamically need to be explicitly parented to the contentItem:

        \note The implicit size of the StatusBar is calculated based on the size of its content. If you want to anchor
        items inside the status bar, you must specify an explicit width and height on the StatusBar itself.
    */
    readonly property alias contentItem: container

    data: [
        Loader {
            id: panelLoader
            anchors.fill: parent
            sourceComponent: styleLoader.item ? styleLoader.item.panel : null
            onLoaded: item.z = -1
            Loader {
                id: styleLoader
                property alias __control: statusbar
                sourceComponent: style
            }
        },
        Item {
            id: container
            z: 1
            focus: true
            anchors.fill: parent

            anchors.topMargin: topMargin
            anchors.leftMargin: leftMargin
            anchors.rightMargin: rightMargin
            anchors.bottomMargin: bottomMargin

            property int topMargin: __style ? __style.padding.top : 0
            property int bottomMargin: __style ? __style.padding.bottom : 0
            property int leftMargin: __style ? __style.padding.left : 0
            property int rightMargin: __style ? __style.padding.right : 0

            property Item layoutItem: container.children.length === 1 ? container.children[0] : null
            property real layoutWidth: layoutItem ? (layoutItem.implicitWidth || layoutItem.width) +
                                                    (layoutItem.anchors.fill ? layoutItem.anchors.leftMargin +
                                                                               layoutItem.anchors.rightMargin : 0) : 0
            property real layoutHeight: layoutItem ? (layoutItem.implicitHeight || layoutItem.height) +
                                                     (layoutItem.anchors.fill ? layoutItem.anchors.topMargin +
                                                                                layoutItem.anchors.bottomMargin : 0) : 0
        }]
}
