/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "filesystem.h"
#include <QFileInfo>

/*
 * Return 0 if file does not exist, 2 if file is directory, 1 otherwise.
 */
int FileSystem::exists(const QString &filename)
{
    QFileInfo fileinfo(filename);
    return fileinfo.exists();
}
