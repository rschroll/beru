/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef FILESERVER_H
#define FILESERVER_H

#include <QObject>
#include "qhttpresponse.h"

class FileServer : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE void serve(const QString &filename, QHttpResponse *response);
};

#endif // FILESERVER_H
