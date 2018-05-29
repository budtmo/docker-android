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
    \qmltype SpinBoxStyle
    \inqmlmodule QtQuick.Controls.Styles
    \since 5.2
    \ingroup controlsstyling
    \brief Provides custom styling for SpinBox

    Example:
    \qml
    SpinBox {
        style: SpinBoxStyle{
            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 20
                border.color: "gray"
                radius: 2
            }
        }
    }
    \endqml
*/

Style {
    id: spinboxStyle

    /*! The \l SpinBox this style is attached to. */
    readonly property SpinBox control: __control

    /*! The content margins of the text field. */
    padding { top: 1 ; left: Math.round(styleData.contentHeight/2) ; right: Math.max(22, Math.round(styleData.contentHeight)) ; bottom: 0 }
    /*! \qmlproperty enumeration horizontalAlignment

        This property defines the default text aligment.

        The supported values are:
        \list
        \li Qt.AlignLeft
        \li Qt.AlignHCenter
        \li Qt.AlignRight
        \endlist

        The default value is Qt.AlignRight
    */
    property int horizontalAlignment: Qt.AlignRight

    /*! The text color. */
    property color textColor: SystemPaletteSingleton.text(control.enabled)

    /*! The text highlight color, used behind selections. */
    property color selectionColor: SystemPaletteSingleton.highlight(control.enabled)

    /*! The highlighted text color, used in selections. */
    property color selectedTextColor: SystemPaletteSingleton.highlightedText(control.enabled)

    /*!
        \qmlproperty enumeration renderType

        Override the default rendering type for the control.

        Supported render types are:
        \list
        \li Text.QtRendering
        \li Text.NativeRendering
        \endlist

        The default value is platform dependent.

        \sa Text::renderType
    */
    property int renderType: Settings.isMobile ? Text.QtRendering : Text.NativeRendering

    /*!
        \since QtQuick.Controls.Styles 1.3
        The font of the control.
    */
    property font font

    /*! The button used to increment the value. */
    property Component incrementControl: Item {
        implicitWidth: padding.right
        Image {
            source: "images/arrow-up.png"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 1
            opacity: control.enabled ? (styleData.upPressed ? 1 : 0.6) : 0.5
        }
    }

    /*! The button used to decrement the value. */
    property Component decrementControl: Item {
        implicitWidth: padding.right
        Image {
            source: "images/arrow-down.png"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
            opacity: control.enabled ? (styleData.downPressed ? 1 : 0.6) : 0.5
        }
    }

    /*! The background of the SpinBox. */
    property Component background: Item {
        implicitHeight: Math.max(25, Math.round(styleData.contentHeight * 1.2))
        implicitWidth: styleData.contentWidth + padding.left + padding.right
        baselineOffset: control.__baselineOffset
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
                GradientStop {color: "#fff" ; position: 0.1}
                GradientStop {color: "#fff" ; position: 1}
            }
            radius: control.font.pixelSize * 0.16
            anchors.fill: parent
            border.color: control.activeFocus ? "#47b" : "#999"
        }
    }

    /*! \internal */
    property Component panel: Item {
        id: styleitem
        implicitWidth: backgroundLoader.implicitWidth
        implicitHeight: backgroundLoader.implicitHeight
        baselineOffset: backgroundLoader.item ? backgroundLoader.item.baselineOffset : 0

        property font font: spinboxStyle.font

        property color foregroundColor: spinboxStyle.textColor
        property color selectionColor: spinboxStyle.selectionColor
        property color selectedTextColor: spinboxStyle.selectedTextColor

        property var margins: spinboxStyle.padding

        property rect upRect: Qt.rect(width - incrementControlLoader.implicitWidth, 0, incrementControlLoader.implicitWidth, height / 2 + 1)
        property rect downRect: Qt.rect(width - decrementControlLoader.implicitWidth, height / 2, decrementControlLoader.implicitWidth, height / 2)

        property int horizontalAlignment: spinboxStyle.horizontalAlignment
        property int verticalAlignment: Qt.AlignVCenter

        Loader {
            id: backgroundLoader
            anchors.fill: parent
            sourceComponent: background
        }

        Loader {
            id: incrementControlLoader
            x: upRect.x
            y: upRect.y
            width: upRect.width
            height: upRect.height
            sourceComponent: incrementControl
        }

        Loader {
            id: decrementControlLoader
            x: downRect.x
            y: downRect.y
            width: downRect.width
            height: downRect.height
            sourceComponent: decrementControl
        }
    }

    /*! \internal
        The cursor handle.
        \since QtQuick.Controls.Styles 1.3

        The parent of the handle is positioned to the top left corner of
        the cursor position. The interactive area is determined by the
        geometry of the handle delegate.

        The following signals and read-only properties are available within the scope
        of the handle delegate:
        \table
            \row \li \b {styleData.activated()} [signal] \li Emitted when the handle is activated ie. the editor is clicked.
            \row \li \b {styleData.pressed} : bool \li Whether the handle is pressed.
            \row \li \b {styleData.position} : int \li The character position of the handle.
            \row \li \b {styleData.lineHeight} : real \li The height of the line the handle is on.
            \row \li \b {styleData.hasSelection} : bool \li Whether the editor has selected text.
        \endtable
    */
    property Component __cursorHandle

    /*! \internal
        The selection handle.
        \since QtQuick.Controls.Styles 1.3

        The parent of the handle is positioned to the top left corner of
        the first selected character. The interactive area is determined
        by the geometry of the handle delegate.

        The following signals and read-only properties are available within the scope
        of the handle delegate:
        \table
            \row \li \b {styleData.activated()} [signal] \li Emitted when the handle is activated ie. the editor is clicked.
            \row \li \b {styleData.pressed} : bool \li Whether the handle is pressed.
            \row \li \b {styleData.position} : int \li The character position of the handle.
            \row \li \b {styleData.lineHeight} : real \li The height of the line the handle is on.
            \row \li \b {styleData.hasSelection} : bool \li Whether the editor has selected text.
        \endtable
    */
    property Component __selectionHandle

    /*! \internal
        The cursor delegate.
        \since QtQuick.Controls.Styles 1.3
    */
    property Component __cursorDelegate
}
