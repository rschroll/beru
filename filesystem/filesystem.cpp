/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "filesystem.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>

bool FileSystem::exists(const QString &filename)
{
    return QFile::exists(filename);
}

QString FileSystem::canonicalFilePath(const QString &filename)
{
    QFileInfo fileinfo(filename);
    return fileinfo.canonicalFilePath();
}

/*
 * Try to find or make a directory for writing data.  We start with ~/dirInHome, but
 * fall back to the relevant XDG_DATA_HOME if that's not working.  Return the path of
 * the directory, or null if we failed.
 */
QString FileSystem::getDataDir(const QString &dirInHome)
{
    QString XDG_data = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + dirInHome;
    QDir dir("");
    if (!dir.mkpath(XDG_data))
        return QString();

    QFileInfo info(XDG_data);
    if (!info.isWritable())
        return QString();

    return XDG_data;
}

QStringList FileSystem::listDir(const QString &dirname, const QStringList &filters)
{
    QDir dir(dirname);
    return dir.entryList(filters, QDir::Files | QDir::Readable);
}
