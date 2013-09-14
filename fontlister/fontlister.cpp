/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "fontlister.h"
#include <QFontDatabase>
#include <QStringList>

QStringList FontLister::families() const
{
    QFontDatabase fonts;
    return fonts.families();
}
