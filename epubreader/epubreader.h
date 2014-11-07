/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef EPUBREADER_H
#define EPUBREADER_H

#include <QObject>
#include <QDomDocument>
#include <QVariant>
#include "quazip/quazip.h"
#include "../qhttpserver/qhttpresponse.h"

class EpubReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hash READ hash)
    Q_PROPERTY(QString title READ title)
public:
    explicit EpubReader(QObject *parent = 0);
    QString hash();
    QString title();
    Q_INVOKABLE bool load(const QString &filename);
    Q_INVOKABLE void serveBookData(QHttpResponse *response);
    Q_INVOKABLE void serveComponent(const QString &filename, QHttpResponse *response);
    Q_INVOKABLE QVariantMap getCoverInfo(int thumbsize, int fullsize);

signals:
    void contentsReady(QVariantList contents);

private:
    QDomDocument *getFileAsDom(const QString &filename);
    bool parseOPF();
    QVariantList getContents();
    QVariantList parseNav();
    QVariantList parseNavList(QDomElement element);
    QVariantList parseNCX();
    QVariantList parseNCXChildren(QDomElement element);

    QuaZip* zip;
    QString _hash;
    QString navhref;
    QString ncxhref;
    QString coverhtml;
    QStringList spine;
    QVariantMap metadata;
    QVariantMap sortmetadata;

};

#endif // EPUBREADER_H
