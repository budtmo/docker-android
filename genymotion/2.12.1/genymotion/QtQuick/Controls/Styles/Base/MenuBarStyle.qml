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
    \qmltype MenuBarStyle
    \inqmlmodule QtQuick.Controls.Styles
    \since 5.3
    \ingroup controlsstyling
    \brief Provides custom styling for MenuBar

    \note Styling menu bars may not be supported on platforms using native menu bars
    through their QPA plugin.
*/

Style {
    id: root

    /*! Returns a formatted string to render mnemonics for a given menu item.

        The mnemonic character is prefixed by an ampersand in the original string.

        Passing \c true for \c underline will underline the mnemonic character (e.g.,
        \c formatMnemonic("&File", true) will return \c "<u>F</u>ile"). Passing \c false
        for \c underline will return the plain text form (e.g., \c formatMnemonic("&File", false)
        will return \c "File").

        \sa Label
    */
    function formatMnemonic(text, underline) {
        return underline ? StyleHelpers.stylizeMnemonics(text) : StyleHelpers.removeMnemonics(text)
    }

    /*! The background for the full menu bar.

        The background will be extended to the full containing window width.
        Its height will always fit all of the menu bar items. The final size
        will include the paddings.
    */
    property Component background: Rectangle {
        color: "#dcdcdc"
        implicitHeight: 20
    }

    /*! The menu bar item.

        \target styleData properties
        This item has to be configured using the \b styleData object which is in scope,
        and contains the following read-only properties:
        \table
            \row \li \b {styleData.index} : int \li The index of the menu item in its menu.
            \row \li \b {styleData.selected} : bool \li \c true if the menu item is selected.
            \row \li \b {styleData.open} : bool \li \c true when the pull down menu is open.
            \row \li \b {styleData.text} : string \li The menu bar item's text.
            \row \li \b {styleData.underlineMnemonic} : bool \li When \c true, the style should underline the menu item's label mnemonic.
        \endtable

    */
    property Component itemDelegate: Rectangle {
        implicitWidth: text.width + 12
        implicitHeight: text.height + 4
        color: styleData.open ? "#49d" : "transparent"

        Text {
            id: text
            font: root.font
            text: formatMnemonic(styleData.text, styleData.underlineMnemonic)
            anchors.centerIn: parent
            renderType: Settings.isMobile ? Text.QtRendering : Text.NativeRendering
            color: styleData.open ? "white" : SystemPaletteSingleton.windowText(control.enabled)
        }
    }

    /*! The style component for the menubar's own menus and their submenus.

        \sa {QtQuick.Controls.Styles::}{MenuStyle}
    */
    property Component menuStyle: MenuStyle {
        font: root.font
    }

    /*!
        \since QtQuick.Controls.Styles 1.3
        The font of the control.
    */
    property font font

    /*! \internal */
    property bool __isNative: true
}
