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
};

#endif // FILEREADER_H
