/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "filesystem.h"
#include <QFileInfo>
#include <QDir>
#include <QDirIterator>
#include <QStandardPaths>
#include <QTemporaryFile>

/*
 * Return 0 if file does not exist, 2 if file is directory, 1 otherwise.
 */
int FileSystem::exists(const QString &filename)
{
    QFileInfo fileinfo(filename);
    if (!fileinfo.exists())
        return 0;
    return fileinfo.isDir() ? 2 : 1;
}

QString FileSystem::canonicalFilePath(const QString &filename)
{
    QFileInfo fileinfo(filename);
    return fileinfo.canonicalFilePath();
}

bool FileSystem::makeDir(const QString &path)
{
    QDir dir("");
    return dir.mkpath(path);
}

QString FileSystem::homePath() const
{
    return QDir::homePath();
}

bool FileSystem::writableHome()
{
    QTemporaryFile temp(QDir::homePath() + "/tmp");
    if (!temp.open())
        return false;
    temp.write("test");
    temp.seek(0);
    return temp.readAll() == "test";
}

/*
 * Get a subdirectory of XDG_DATA_HOME.  Return the path of the directory, or the empty string
 * if something went wrong.
 */
QString FileSystem::getDataDir(const QString &subDir)
{
    QString XDG_data = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + subDir;
    QDir dir("");
    if (!dir.mkpath(XDG_data))
        return QString();

    QFileInfo info(XDG_data);
    if (!info.isWritable())
        return QString();

    return XDG_data;
}

/*
 * Return the absolute path of all files within dirname or its subdirectories that match filters.
 */
QStringList FileSystem::listDir(const QString &dirname, const QStringList &filters)
{
    QStringList files;
    QDirIterator iter(dirname, filters, QDir::Files | QDir::Readable, QDirIterator::Subdirectories);
    while (iter.hasNext())
        files.append(iter.next());
    return files;
}
