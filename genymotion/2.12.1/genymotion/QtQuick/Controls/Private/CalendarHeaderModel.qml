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

/*
    CalendarHeaderModel contains a list of the days of a week,
    according to a \l locale. The \l locale affects which day of the week
    is first in the model.

    The only role provided by the model is \c dayOfWeek, which is one of the
    following JavaScript values:

    \list
    \li \c Locale.Sunday
    \li \c Locale.Monday
    \li \c Locale.Tuesday
    \li \c Locale.Wednesday
    \li \c Locale.Thursday
    \li \c Locale.Friday
    \li \c Locale.Saturday
    \endlist
 */

ListModel {
    id: root

    /*
        The locale that this model should be based on.
        This affects which day of the week is first in the model.
    */
    property var locale

    ListElement {
        dayOfWeek: Locale.Sunday
    }
    ListElement {
        dayOfWeek: Locale.Monday
    }
    ListElement {
        dayOfWeek: Locale.Tuesday
    }
    ListElement {
        dayOfWeek: Locale.Wednesday
    }
    ListElement {
        dayOfWeek: Locale.Thursday
    }
    ListElement {
        dayOfWeek: Locale.Friday
    }
    ListElement {
        dayOfWeek: Locale.Saturday
    }

    Component.onCompleted: {
        var daysOfWeek = [Locale.Sunday, Locale.Monday, Locale.Tuesday,
            Locale.Wednesday, Locale.Thursday, Locale.Friday, Locale.Saturday];
        var firstDayOfWeek = root.locale.firstDayOfWeek;

        var shifted = daysOfWeek.splice(firstDayOfWeek, daysOfWeek.length - firstDayOfWeek);
        daysOfWeek = shifted.concat(daysOfWeek)

        if (firstDayOfWeek !== Locale.Sunday) {
            for (var i = 0; i < daysOfWeek.length; ++i) {
                root.setProperty(i, "dayOfWeek", daysOfWeek[i]);
            }
        }
    }
}
