/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL license. See the file COPYING for full details.
 */

#ifndef FILEREADERPLUGIN_H
#define FILEREADERPLUGIN_H

#include <QQmlExtensionPlugin>

class FileReaderPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "io.github.rschroll.FileReader")

public:
    void registerTypes(const char *uri);
};

#endif // FILEREADERPLUGIN_H
