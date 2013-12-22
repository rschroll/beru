/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "filereaderplugin.h"
#include "filereader.h"
#include <qqml.h>

void FileSystemPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<FileSystem>(uri, 1, 0, "FileSystem");
}
