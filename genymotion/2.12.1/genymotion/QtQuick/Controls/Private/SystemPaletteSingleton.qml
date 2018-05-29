/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL21$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia. For licensing terms and
** conditions see http://qt.digia.com/licensing. For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 or version 3 as published by the Free
** Software Foundation and appearing in the file LICENSE.LGPLv21 and
** LICENSE.LGPLv3 included in the packaging of this file. Please review the
** following information to ensure the GNU Lesser General Public License
** requirements will be met: https://www.gnu.org/licenses/lgpl.html and
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights. These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** $QT_END_LICENSE$
**
****************************************************************************/

pragma Singleton
import QtQuick 2.2

QtObject {
    property SystemPalette active: SystemPalette { colorGroup: SystemPalette.Active }
    property SystemPalette disabled: SystemPalette { colorGroup: SystemPalette.Disabled }

    function alternateBase(enabled) { return enabled ? active.alternateBase : disabled.alternateBase }
    function base(enabled) { return enabled ? active.base : disabled.base }
    function button(enabled) { return enabled ? active.button : disabled.button }
    function buttonText(enabled) { return enabled ? active.buttonText : disabled.buttonText }
    function dark(enabled) { return enabled ? active.dark : disabled.dark }
    function highlight(enabled) { return enabled ? active.highlight : disabled.highlight }
    function highlightedText(enabled) { return enabled ? active.highlightedText : disabled.highlightedText }
    function light(enabled) { return enabled ? active.light : disabled.light }
    function mid(enabled) { return enabled ? active.mid : disabled.mid }
    function midlight(enabled) { return enabled ? active.midlight : disabled.midlight }
    function shadow(enabled) { return enabled ? active.shadow : disabled.shadow }
    function text(enabled) { return enabled ? active.text : disabled.text }
    function window(enabled) { return enabled ? active.window : disabled.window }
    function windowText(enabled) { return enabled ? active.windowText : disabled.windowText }
}
