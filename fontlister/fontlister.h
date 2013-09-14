/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef FONTlISTER_H
#define FONTLISTER_H

#include <QObject>
#include <QStringList>

class FontLister : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE QStringList families() const;
};

#endif // FONTLISTER_H
