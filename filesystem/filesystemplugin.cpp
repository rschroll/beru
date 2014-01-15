/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "filesystemplugin.h"
#include "filesystem.h"
#include <qqml.h>

void FileSystemPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<FileSystem>(uri, 1, 0, "FileSystem");
}
