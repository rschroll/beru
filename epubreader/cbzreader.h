/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef CBZREADER_H
#define CBZREADER_H

#include <QObject>
#include <QDomDocument>
#include <QVariant>
#include "quazip/quazip.h"
#include "../qhttpserver/qhttpresponse.h"

class CBZReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hash READ hash)
    Q_PROPERTY(QString title READ title)
public:
    explicit CBZReader(QObject *parent = 0);
    QString hash();
    QString title();
    Q_INVOKABLE bool load(const QString &filename);
    Q_INVOKABLE void serveBookData(QHttpResponse *response);
    Q_INVOKABLE void serveComponent(const QString &filename, QHttpResponse *response);
    Q_INVOKABLE QVariantMap getCoverInfo(int thumbsize, int fullsize);

signals:
    void contentsReady(QVariantList contents);

private:
    bool parse();
    QVariantList getContents();

    QuaZip* zip;
    QString _hash;
    QStringList spine;

};

#endif // CBZREADER_H
