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

.pragma library

var daysInAWeek = 7;
var monthsInAYear = 12;

// Not the number of weeks per month, but the number of weeks that are
// shown on a typical calendar.
var weeksOnACalendarMonth = 6;

// Can't create year 1 directly...
var minimumCalendarDate = new Date(-1, 0, 1);
minimumCalendarDate.setFullYear(minimumCalendarDate.getFullYear() + 2);
var maximumCalendarDate = new Date(275759, 9, 25);

function daysInMonth(date) {
    // Passing 0 as the day will give us the previous month, which will be
    // date.getMonth() since we added 1 to it.
    return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
}

/*!
    Returns a copy of \a date with its month set to \a month, keeping the same
    day if possible. Does not modify \a date.
*/
function setMonth(date, month) {
    var oldDay = date.getDate();
    var newDate = new Date(date);
    // Set the day first, because setting the month could cause it to skip ahead
    // a month if the day is larger than the latest day in that month.
    newDate.setDate(1);
    newDate.setMonth(month);
    // We'd like to have the previous day still selected when we change
    // months, but it might not be possible, so use the smallest of the two.
    newDate.setDate(Math.min(oldDay, daysInMonth(newDate)));
    return newDate;
}

/*!
    Returns the cell rectangle for the cell at the given \a index, assuming
    that the grid has a number of columns equal to \a columns and rows
    equal to \a rows, with an available width of \a availableWidth and height
    of \a availableHeight.

    If \a gridLineWidth is greater than \c 0, the cell rectangle will be
    calculated under the assumption that there is a grid between the cells:

        31 |  1 |  2 |  3 |  4 |  5 |  6
        --------------------------------
         7 |  8 |  9 | 10 | 11 | 12 | 13
        --------------------------------
        14 | 15 | 16 | 17 | 18 | 19 | 20
        --------------------------------
        21 | 22 | 23 | 24 | 25 | 26 | 27
        --------------------------------
        28 | 29 | 30 | 31 |  1 |  2 |  3
        --------------------------------
         4 |  5 |  6 |  7 |  8 |  9 | 10
*/
function cellRectAt(index, columns, rows, availableWidth, availableHeight, gridLineWidth) {
    var col = Math.floor(index % columns);
    var row = Math.floor(index / columns);

    var availableWidthMinusGridLines = availableWidth - ((columns - 1) * gridLineWidth);
    var availableHeightMinusGridLines = availableHeight - ((rows - 1) * gridLineWidth);
    var remainingHorizontalSpace = Math.floor(availableWidthMinusGridLines % columns);
    var remainingVerticalSpace = Math.floor(availableHeightMinusGridLines % rows);
    var baseCellWidth = Math.floor(availableWidthMinusGridLines / columns);
    var baseCellHeight = Math.floor(availableHeightMinusGridLines / rows);

    var rect = Qt.rect(0, 0, 0, 0);

    rect.x = baseCellWidth * col;
    rect.width = baseCellWidth;
    if (remainingHorizontalSpace > 0) {
        if (col < remainingHorizontalSpace) {
            ++rect.width;
        }

        // This cell's x position should be increased by 1 for every column above it.
        rect.x += Math.min(remainingHorizontalSpace, col);
    }

    rect.y = baseCellHeight * row;
    rect.height = baseCellHeight;
    if (remainingVerticalSpace > 0) {
        if (row < remainingVerticalSpace) {
            ++rect.height;
        }

        // This cell's y position should be increased by 1 for every row above it.
        rect.y += Math.min(remainingVerticalSpace, row);
    }

    rect.x += col * gridLineWidth;
    rect.y += row * gridLineWidth;

    return rect;
}
