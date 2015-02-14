/* Copyright 2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1


Button {
    property bool primary: true
    color: primary ? UbuntuColors.orange : UbuntuColors.warmGrey
}
