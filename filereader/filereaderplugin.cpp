/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "filereaderplugin.h"
#include "filereader.h"
#include <qqml.h>

void FileReaderPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<FileReader>(uri, 1, 0, "FileReader");
}
