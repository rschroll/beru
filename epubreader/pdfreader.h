/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#ifndef PDFREADER_H
#define PDFREADER_H

#include <QObject>
//#include <QDomDocument>
#include <QVariant>
#include <poppler/qt5/poppler-qt5.h>
#include "../qhttpserver/qhttpresponse.h"

class PDFReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hash READ hash)
    Q_PROPERTY(QString title READ title)
public:
    explicit PDFReader(QObject *parent = 0);
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
    void computeHash(const QString &filename);

    Poppler::Document* pdf;
    QString _hash;
    QStringList spine;

};

#endif // PDFREADER_H
