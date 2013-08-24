/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef EPUBREADERPLUGIN_H
#define EPUBREADERPLUGIN_H

#include <QQmlExtensionPlugin>

class EpubReaderPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "io.github.rschroll.EpubReader")

public:
    void registerTypes(const char *uri);
};

#endif // EPUBREADERPLUGIN_H
