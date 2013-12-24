/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef FILESYSTEMPLUGIN_H
#define FILESYSTEMPLUGIN_H

#include <QQmlExtensionPlugin>

class FileSystemPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "io.github.rschroll.FileReader")

public:
    void registerTypes(const char *uri);
};

#endif // FILESYSTEMPLUGIN_H
