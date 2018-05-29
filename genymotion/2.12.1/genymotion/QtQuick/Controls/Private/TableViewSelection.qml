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

QtObject {

    property int count: 0
    signal selectionChanged

    property bool __dirty: false
    property var __ranges: []

    function forEach (callback) {
        if (!(callback instanceof Function)) {
            console.warn("TableViewSelection.forEach: argument is not a function")
            return;
        }
        __forEach(callback, -1)
    }

    function contains(index) {
        for (var i = 0 ; i < __ranges.length ; ++i) {
            if (__ranges[i][0] <= index && index <= __ranges[i][1])
                return true;
            else if (__ranges[i][0] > index)
                return false;
        }
        return false;
    }

    function clear() {
        __ranges = []
        __dirty = true
        count = 0
        selectionChanged()
    }

    function selectAll() { select(0, rowCount - 1) }
    function select(first, last) { __select(true, first, last) }
    function deselect(first, last) { __select(false, first, last) }

    // --- private section ---

    function __printRanges() {
        var out = ""
        for (var i = 0 ; i < __ranges.length ; ++ i)
            out += ("{" + __ranges[i][0] + "," + __ranges[i][1] + "} ")
        print(out)
    }

    function __count() {
        var sum = 0
        for (var i = 0 ; i < __ranges.length ; ++i) {
            sum += (1 + __ranges[i][1] - __ranges[i][0])
        }
        return sum
    }

    function __forEach (callback, startIndex) {
        __dirty = false
        var i, j

        for (i = 0 ; i < __ranges.length && !__dirty ; ++i) {
            for (j = __ranges[i][0] ; !__dirty && j <= __ranges[i][1] ; ++j) {
                if (j >= startIndex)
                    callback.call(this, j)
            }
        }

        // Restart iteration at last index if selection changed
        if (__dirty)
            return __forEach(callback, j)
    }

    function __selectOne(index) {
        __ranges = [[index, index]]
        __dirty = true
        count = 1
        selectionChanged();
    }

    function __select(select, first, last) {

        var i, range
        var start = first
        var stop = first
        var startRangeIndex = -1
        var stopRangeIndex = -1
        var newRangePos = 0

        if (first < 0 || last < 0 || first >= rowCount || last >=rowCount) {
            console.warn("TableViewSelection: index out of range")
            return
        }

        if (last !== undefined) {
            start = first <= last ? first : last
            stop = first <= last ? last : first
        }

        if (select) {

            // Find beginning and end ranges
            for (i = 0 ; i < __ranges.length; ++ i) {
                range = __ranges[i]
                if (range[0] > stop + 1) continue;  // above range
                if (range[1] < start - 1) { // below range
                    newRangePos = i + 1
                    continue;
                }
                if (startRangeIndex === -1)
                    startRangeIndex = i
                stopRangeIndex = i
            }

            if (startRangeIndex !== -1)
                start = Math.min(__ranges[startRangeIndex][0], start)
            if (stopRangeIndex !== -1)
                stop = Math.max(__ranges[stopRangeIndex][1], stop)

            if (startRangeIndex  === -1)
                startRangeIndex = newRangePos

            __ranges.splice(Math.max(0, startRangeIndex),
                            1 + stopRangeIndex - startRangeIndex, [start, stop])

        } else {

            // Find beginning and end ranges
            for (i = 0 ; i < __ranges.length; ++ i) {
                range = __ranges[i]
                if (range[1] < start) continue; // below range
                if (range[0] > stop) continue;  // above range
                if (startRangeIndex === -1)
                    startRangeIndex = i
                stopRangeIndex = i
            }

            // Slice ranges accordingly
            if (startRangeIndex >= 0 && stopRangeIndex >= 0) {
                var startRange = __ranges[startRangeIndex]
                var stopRange = __ranges[stopRangeIndex]
                var length = 1 + stopRangeIndex - startRangeIndex
                if (start <= startRange[0] && stop >= stopRange[1]) { //remove
                    __ranges.splice(startRangeIndex, length)
                } else if (start - 1 < startRange[0] && stop <= stopRange[1]) { //cut front
                    __ranges.splice(startRangeIndex, length, [stop + 1, stopRange[1]])
                } else if (start - 1 < startRange[1] && stop >= stopRange[1]) { // cut back
                    __ranges.splice(startRangeIndex, length, [startRange[0], start - 1])
                } else { //split
                    __ranges.splice(startRangeIndex, length, [startRange[0], start - 1], [stop + 1, stopRange[1]])
                }
            }
        }
        __dirty = true
        count = __count()  // forces a re-evaluation of indexes in the delegates
        selectionChanged()
    }
}
