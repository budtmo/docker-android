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
import QtQuick.Layouts 1.1

Item {
    id: contentItem
    property real minimumWidth: __calcMinimum('Width')
    property real minimumHeight: __calcMinimum('Height')
    property real maximumWidth: Number.POSITIVE_INFINITY
    property real maximumHeight: Number.POSITIVE_INFINITY
    implicitWidth: __calcImplicitWidth()
    implicitHeight: __calcImplicitHeight()

    /*! \internal */
    property Item __layoutItem: contentItem.children.length === 1 ? contentItem.children[0] : null
    /*! \internal */
    property real __marginsWidth: __layoutItem ? __layoutItem.anchors.leftMargin + __layoutItem.anchors.rightMargin : 0
    /*! \internal */
    property real __marginsHeight: __layoutItem ? __layoutItem.anchors.topMargin + __layoutItem.anchors.bottomMargin : 0

    /*! \internal */
    property bool __noMinimumWidthGiven : false
    /*! \internal */
    property bool __noMinimumHeightGiven : false
    /*! \internal */
    property bool __noImplicitWidthGiven : false
    /*! \internal */
    property bool __noImplicitHeightGiven : false

    function __calcImplicitWidth() {
        if (__layoutItem && __layoutItem.anchors.fill)
            return __calcImplicit('Width')
        return contentItem.childrenRect.x + contentItem.childrenRect.width
    }

    function __calcImplicitHeight() {
        if (__layoutItem && __layoutItem.anchors.fill)
            return __calcImplicit('Height')
        return contentItem.childrenRect.y + contentItem.childrenRect.height
    }

    function __calcImplicit(hw) {
        var pref = __layoutItem.Layout['preferred' + hw]
        if (pref < 0) {
            pref = __layoutItem['implicit' + hw]
        }
        contentItem['__noImplicit' + hw + 'Given'] = (pref === 0 ? true : false)
        pref += contentItem['__margins' + hw]
        return pref
    }

    function __calcMinimum(hw) {  // hw is 'Width' or 'Height'
        return (__layoutItem && __layoutItem.anchors.fill) ? __calcMinMax('minimum', hw) : 0
    }

    function __calcMaximum(hw) {  // hw is 'Width' or 'Height'
        return (__layoutItem && __layoutItem.anchors.fill) ? __calcMinMax('maximum', hw) : Number.POSITIVE_INFINITY
    }

    function __calcMinMax(minMaxConstraint, hw) {
        var attachedPropName = minMaxConstraint + hw
        var extent = __layoutItem.Layout[attachedPropName]

        if (minMaxConstraint === 'minimum')
            contentItem['__noMinimum' + hw + 'Given'] = (extent === 0 ? true : false)

        extent += contentItem['__margins' + hw]
        return extent
    }
}
