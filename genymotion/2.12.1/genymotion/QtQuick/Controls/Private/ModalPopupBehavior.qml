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

// KNOWN ISSUES
// none

/*!
        \qmltype ModalPopupBehavior
        \internal
        \inqmlmodule QtQuick.Controls.Private
*/
Item {
    id: popupBehavior

    property bool showing: false
    property bool whenAlso: true            // modifier to the "showing" property
    property bool consumeCancelClick: true
    property int delay: 0                   // delay before popout becomes visible
    property int deallocationDelay: 3000    // 3 seconds

    property Component popupComponent

    property alias popup: popupLoader.item  // read-only
    property alias window: popupBehavior.root // read-only

    signal prepareToShow
    signal prepareToHide
    signal cancelledByClick

    // implementation

    anchors.fill: parent

    onShowingChanged: notifyChange()
    onWhenAlsoChanged: notifyChange()
    function notifyChange() {
        if(showing && whenAlso) {
            if(popupLoader.sourceComponent == undefined) {
                popupLoader.sourceComponent = popupComponent;
            }
        } else {
            mouseArea.enabled = false; // disable before opacity is changed in case it has fading behavior
            if(Qt.isQtObject(popupLoader.item)) {
                popupBehavior.prepareToHide();
                popupLoader.item.opacity = 0;
            }
        }
    }

    property Item root: findRoot()
    function findRoot() {
        var p = parent;
        while(p.parent != undefined)
            p = p.parent;

        return p;
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: false  // enabled only when popout is showing
        onPressed: {
            popupBehavior.showing = false;
            mouse.accepted = consumeCancelClick;
            cancelledByClick();
        }
    }

    Loader {
        id: popupLoader
    }

    Timer { // visibility timer
        running: Qt.isQtObject(popupLoader.item) && showing && whenAlso
        interval: delay
        onTriggered: {
            popupBehavior.prepareToShow();
            mouseArea.enabled = true;
            popup.opacity = 1;
        }
    }

    Timer { // deallocation timer
        running: Qt.isQtObject(popupLoader.item) && popupLoader.item.opacity == 0
        interval: deallocationDelay
        onTriggered: popupLoader.sourceComponent = undefined
    }

    states: State {
        name: "active"
        when: Qt.isQtObject(popupLoader.item) && popupLoader.item.opacity > 0
        ParentChange { target: popupBehavior; parent: root }
    }
 }

