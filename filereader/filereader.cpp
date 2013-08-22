/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "filereader.h"
#include <QFile>
#include <QFileInfo>

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
