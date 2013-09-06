/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "filereader.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>

QByteArray FileReader::read(const QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly))
        return QByteArray();

    return file.readAll();
}

QString FileReader::read_b64(const QString &filename)
{
    return this->read(filename).toBase64();
}

bool FileReader::exists(const QString &filename)
{
    return QFile::exists(filename);
}

QString FileReader::canonicalFilePath(const QString &filename)
{
    QFileInfo fileinfo(filename);
    return fileinfo.canonicalFilePath();
}

QString FileReader::homePath() const
{
    return QDir::homePath();
}
#include <QDebug>
bool FileReader::ensureDirInHome(const QString &dirname)
{
    QDir home = QDir::home();
    if (!home.mkpath(dirname))
        return false;

    QFileInfo info(home, dirname);
    return info.isWritable();
}

/*
 * Try to find or make a directory for writing data.  We start with ~/dirInHome, but
 * fall back to the relevant XDG_DATA_HOME if that's not working.  Return the path of
 * the directory, or null if we failed.
 */
QString FileReader::getDataDir(const QString &dirInHome)
{
    if (this->ensureDirInHome(dirInHome))
        return QDir::homePath() + "/" + dirInHome;

    QString XDG_data = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QDir dir("");
    if (!dir.mkpath(XDG_data))
        return QString();

    QFileInfo info(XDG_data);
    if (!info.isWritable())
        return QString();

    return XDG_data;
}
