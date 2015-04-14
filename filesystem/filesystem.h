/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>
#include <QStringList>

class FileSystem : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE int exists(const QString &filename);
};

#endif // FILESYSTEM_H
