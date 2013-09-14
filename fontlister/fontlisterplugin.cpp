/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "fontlisterplugin.h"
#include "fontlister.h"
#include <qqml.h>

void FontListerPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<FontLister>(uri, 1, 0, "FontLister");
}
