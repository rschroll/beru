/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef FONTLISTERPLUGIN_H
#define FONTLISTERPLUGIN_H

#include <QQmlExtensionPlugin>

class FontListerPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "io.github.rschroll.FontLister")

public:
    void registerTypes(const char *uri);
};

#endif // FONTLISTERPLUGIN_H
