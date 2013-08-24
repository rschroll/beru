/* Copyright 2013 Robert Schroll
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
public:
    explicit EpubReader(QObject *parent = 0);
    Q_INVOKABLE bool load(const QString &filename);
    Q_INVOKABLE void serveBookData(QHttpResponse *response);
    Q_INVOKABLE void serveComponent(const QString &filename, QHttpResponse *response);

signals:
    void contentsReady(QVariantList contents);

private:
    QDomDocument *getFileAsDom(const QString &filename);
    bool parseOPF();
    QVariantList getContents();
    QVariantList parseNav();
    QVariantList parseNavList(QDomElement element, QString navdir);
    QVariantList parseNCX();
    QVariantList parseNCXChildren(QDomElement element, QString navdir);

    QuaZip* zip;
    QString navhref;
    QString ncxhref;
    QStringList spine;
    QVariantMap metadata;

};

#endif // EPUBREADER_H
