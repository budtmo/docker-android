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
    \qmltype Slider
    \inqmlmodule QtQuick.Controls
    \since 5.1
    \ingroup controls
    \brief Provides a vertical or horizontal slider control.

    \image slider.png

    The slider is the classic control for providing a bounded value. It lets
    the user move a slider handle along a horizontal or vertical groove
    and translates the handle's position into a value within the legal range.

    \code
    Slider {
        value: 0.5
    }
    \endcode

    The slider value is by default in the range [0, 1]. If integer values are
    needed, you can set the \l stepSize.

    You can create a custom appearance for a Slider by
    assigning a \l {QtQuick.Controls.Styles::SliderStyle}{SliderStyle}.
*/

Control {
    id: slider

    /*!
        \qmlproperty enumeration Slider::orientation

        This property holds the layout orientation of the slider.
        The default value is \c Qt.Horizontal.
    */
    property int orientation: Qt.Horizontal

    /*!
        \qmlproperty real Slider::minimumValue

        This property holds the minimum value of the slider.
        The default value is \c{0.0}.
    */
    property alias minimumValue: range.minimumValue

    /*!
        \qmlproperty real Slider::maximumValue

        This property holds the maximum value of the slider.
        The default value is \c{1.0}.
    */
    property alias maximumValue: range.maximumValue

    /*!
        \qmlproperty bool Slider::updateValueWhileDragging

        This property indicates whether the current \l value should be updated while
        the user is moving the slider handle, or only when the button has been released.
        This property could for instance be modified if changing the slider value would turn
        out to be too time consuming.

        The default value is \c true.
    */
    property bool updateValueWhileDragging: true

    /*!
        \qmlproperty bool Slider::pressed

        This property indicates whether the slider handle is being pressed.
    */
    readonly property alias pressed: mouseArea.pressed

    /*!
        \qmlproperty bool Slider::hovered

        This property indicates whether the slider handle is being hovered.
    */
    readonly property alias hovered: mouseArea.handleHovered

    /*!
        \qmlproperty real Slider::stepSize

        This property indicates the slider step size.

        A value of 0 indicates that the value of the slider operates in a
        continuous range between \l minimumValue and \l maximumValue.

        Any non 0 value indicates a discrete stepSize. The following example
        will generate a slider with integer values in the range [0-5].

        \qml
        Slider {
            maximumValue: 5.0
            stepSize: 1.0
        }
        \endqml

        The default value is \c{0.0}.
    */
    property alias stepSize: range.stepSize

    /*!
        \qmlproperty real Slider::value

        This property holds the current value of the slider.
        The default value is \c{0.0}.
    */
    property alias value: range.value

    /*!
        \qmlproperty bool Slider::activeFocusOnPress

        This property indicates whether the slider should receive active focus when
        pressed.
    */
    property bool activeFocusOnPress: false

    /*!
        \qmlproperty bool Slider::tickmarksEnabled

        This property indicates whether the slider should display tickmarks
        at step intervals. Tick mark spacing is calculated based on the
        \l stepSize property.

        The default value is \c false.

        \note This property may be ignored on some platforms when using the native style (e.g. Android).
    */
    property bool tickmarksEnabled: false

    /*! \internal */
    property bool __horizontal: orientation === Qt.Horizontal

    /*! \internal
        The extra arguments positionAtMinimum and positionAtMaximum are there to force
        re-evaluation of the handle position when the constraints change (QTBUG-41255).
    */
    property real __handlePos: range.valueForPosition(__horizontal ? fakeHandle.x : fakeHandle.y, range.positionAtMinimum, range.positionAtMaximum)

    activeFocusOnTab: true

    Accessible.role: Accessible.Slider
    /*! \internal */
    function accessibleIncreaseAction() {
        range.increaseSingleStep()
    }
    /*! \internal */
    function accessibleDecreaseAction() {
        range.decreaseSingleStep()
    }

    style: Qt.createComponent(Settings.style + "/SliderStyle.qml", slider)

    Keys.onRightPressed: if (__horizontal) range.increaseSingleStep()
    Keys.onLeftPressed: if (__horizontal) range.decreaseSingleStep()
    Keys.onUpPressed: if (!__horizontal) range.increaseSingleStep()
    Keys.onDownPressed: if (!__horizontal) range.decreaseSingleStep()

    RangeModel {
        id: range
        minimumValue: 0.0
        maximumValue: 1.0
        value: 0
        stepSize: 0.0
        inverted: __horizontal ? false : true

        positionAtMinimum: 0
        positionAtMaximum: __horizontal ? slider.width - fakeHandle.width : slider.height - fakeHandle.height
    }

    Item {
        id: fakeHandle
        anchors.verticalCenter: __horizontal ? parent.verticalCenter : undefined
        anchors.horizontalCenter: !__horizontal ? parent.horizontalCenter : undefined
        width: __panel.handleWidth
        height: __panel.handleHeight

        function updatePos() {
            if (updateValueWhileDragging && !mouseArea.drag.active)
                            range.position = __horizontal ? x : y
        }

        onXChanged: updatePos();
        onYChanged: updatePos();
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: Settings.hoverEnabled
        property int clickOffset: 0
        property real pressX: 0
        property real pressY: 0
        property bool handleHovered: false

        function clamp ( val ) {
            return Math.max(range.positionAtMinimum, Math.min(range.positionAtMaximum, val))
        }

        function updateHandlePosition(mouse, force) {
            var pos, overThreshold
            if (__horizontal) {
                pos = clamp (mouse.x + clickOffset - fakeHandle.width/2)
                overThreshold = Math.abs(mouse.x - pressX) >= Settings.dragThreshold
                if (overThreshold)
                    preventStealing = true
                if (overThreshold || force)
                    fakeHandle.x = pos
            } else if (!__horizontal) {
                pos = clamp (mouse.y + clickOffset- fakeHandle.height/2)
                overThreshold = Math.abs(mouse.y - pressY) >= Settings.dragThreshold
                if (overThreshold)
                    preventStealing = true
                if (overThreshold || force)
                    fakeHandle.y = pos
            }
        }

        onPositionChanged: {
            if (pressed)
                updateHandlePosition(mouse, preventStealing)

            var point = mouseArea.mapToItem(fakeHandle, mouse.x, mouse.y)
            handleHovered = fakeHandle.contains(Qt.point(point.x, point.y))
        }

        onPressed: {
            if (slider.activeFocusOnPress)
                slider.forceActiveFocus();

            if (handleHovered) {
                var point = mouseArea.mapToItem(fakeHandle, mouse.x, mouse.y)
                clickOffset = __horizontal ? fakeHandle.width/2 - point.x : fakeHandle.height/2 - point.y
            }
            pressX = mouse.x
            pressY = mouse.y
            updateHandlePosition(mouse, !Settings.hasTouchScreen)
        }

        onReleased: {
            updateHandlePosition(mouse, Settings.hasTouchScreen)
            // If we don't update while dragging, this is the only
            // moment that the range is updated.
            if (!slider.updateValueWhileDragging)
                range.position = __horizontal ? fakeHandle.x : fakeHandle.y;
            clickOffset = 0
            preventStealing = false
        }

        onExited: handleHovered = false
    }


    // During the drag, we simply ignore the position set from the range, this
    // means that setting a value while dragging will not "interrupt" the
    // dragging activity.
    Binding {
        when: !mouseArea.drag.active
        target: fakeHandle
        property: __horizontal ? "x" : "y"
        value: range.position
    }

    WheelArea {
        id: wheelarea
        anchors.fill: parent
        horizontalMinimumValue: slider.minimumValue
        horizontalMaximumValue: slider.maximumValue
        verticalMinimumValue: slider.minimumValue
        verticalMaximumValue: slider.maximumValue
        property real step: (slider.maximumValue - slider.minimumValue)/(range.positionAtMaximum - range.positionAtMinimum)

        onVerticalWheelMoved: {
            if (verticalDelta !== 0) {
                var delta = Math.abs(verticalDelta)*step > stepSize ? verticalDelta*step : verticalDelta/Math.abs(verticalDelta)*stepSize
                value += delta
            }
        }

        onHorizontalWheelMoved: {
            if (horizontalDelta !== 0) {
                var delta = Math.abs(horizontalDelta)*step > stepSize ? horizontalDelta*step : horizontalDelta/Math.abs(horizontalDelta)*stepSize
                value += delta
            }
        }
    }
}
