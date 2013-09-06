/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>

class FileReader : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE QByteArray read(const QString &filename);
    Q_INVOKABLE QString read_b64(const QString &filename);
    Q_INVOKABLE bool exists(const QString &filename);
    Q_INVOKABLE QString canonicalFilePath(const QString &filename);
    Q_INVOKABLE QString homePath() const;
    Q_INVOKABLE bool ensureDirInHome(const QString &dirname);
    Q_INVOKABLE QString getDataDir(const QString &dirInHome);
};

#endif // FILEREADER_H
