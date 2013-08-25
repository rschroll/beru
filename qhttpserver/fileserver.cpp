/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "fileserver.h"
#include <QFile>
#include <../mimetype/mimetype.h>

void FileServer::serve(const QString &filename, QHttpResponse *response)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly)) {
        response->writeHead(404);
        response->end("File not found");
        return;
    }

    response->setHeader("Content-Type", guessMimeType(filename));
    response->writeHead(200);
    response->write(file.readAll());
    response->end();
}
