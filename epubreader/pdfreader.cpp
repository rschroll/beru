/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "pdfreader.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QtGui/QImage>
#include <QBuffer>
#include <QDir>
#include <QCryptographicHash>
#include "quazip/quazip.h"
#include "quazip/quazipfile.h"
#include "../qhttpserver/qhttpresponse.h"

QString guessMimeType(const QString &filename);

PDFReader::PDFReader(QObject *parent) :
    QObject(parent)
{
    this->pdf = NULL;
}

bool PDFReader::load(const QString &filename)
{
    if (this->pdf != NULL) {
        delete this->pdf;
        this->pdf = NULL;
    }
    this->_hash = "";
    this->spine.clear();
    this->metadata.clear();

    this->pdf = Poppler::Document::load(filename.toLatin1());
    if (this->pdf == NULL)
        return false;
    if (!this->parse()) {
        delete this->pdf;
        this->pdf = NULL;
        return false;
    }
    this->computeHash(filename);
    this->readMetadata();
    return true;
}

bool PDFReader::parse() {
    int n = this->pdf->numPages();
    for (int i=0; i<n; i++)
        this->spine.append(QString::number(i + 1));
    return true;
}

void PDFReader::readMetadata() {
    QStringList keys = this->pdf->infoKeys();
    foreach (QString k, keys)
        this->metadata[k.toLower()] = this->pdf->info(k);
}

QString PDFReader::hash() {
    return this->_hash;
}

void PDFReader::computeHash(const QString &filename) {
    // Doing a MD5 hash of the whole file can take a while, so we only
    // do the first 10 kB.  Hopefully that's enough to be unique.
    QFile file(filename);
    if (file.open(QFile::ReadOnly)) {
        QByteArray data = file.read(10 * 1024);
        QCryptographicHash hash(QCryptographicHash::Md5);
        hash.addData(data);
        this->_hash = hash.result().toHex();
    }
}

QString PDFReader::title() {
    return this->metadata.contains("title") ? this->metadata["title"].toString() : "";
}

void PDFReader::serveComponent(const QString &filename, QHttpResponse *response)
{
    if (!this->pdf) {
        response->writeHead(500);
        response->end("PDF file not open for reading");
        return;
    }

    bool success;
    int pageNum = filename.toInt(&success) - 1;
    if (!success || pageNum >= this->pdf->numPages() || pageNum < 0) {
        response->writeHead(404);
        response->end("Could not find page" + filename + " in pdf file");
        return;
    }

    Poppler::Page *page = this->pdf->page(pageNum);
    QImage pageImage = page->renderToImage();
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    pageImage.save(&buffer, "PNG");

    response->setHeader("Content-Type", guessMimeType("png"));
    response->writeHead(200);
    // Important -- use write instead of end, so binary data doesn't get messed up!
    response->write(byteArray);
    response->end();
}

QVariantList PDFReader::getContents()
{
    QVariantList res;
    for (int i=0; i<this->spine.length(); i++) {
        QVariantMap entry;
        entry["title"] = "%PAGE% " + QString::number(i + 1);
        entry["src"] = this->spine[i];
        res.append(entry);
    }
    emit contentsReady(res);
    return res;
}

void PDFReader::serveBookData(QHttpResponse *response)
{
    if (!this->pdf) {
        response->writeHead(500);
        response->end("PDF file not open for reading");
        return;
    }

    response->setHeader("Content-Type", guessMimeType("js"));
    response->writeHead(200);
    QJsonDocument spine(QJsonArray::fromStringList(this->spine));
    QJsonDocument contents(QJsonArray::fromVariantList(this->getContents()));
    QJsonDocument metadata(QJsonObject::fromVariantMap(this->metadata));
    QString res = "var bookData = {" \
            "getComponents: function () { return %1; }, " \
            "getContents:   function () { return %2; }, " \
            "getComponent:  function (component) { return " \
            "\"<img style='display: block; margin: auto; max-height: 100% !important' src='\"" \
            "+ component + \"' />\"; }, " \
            "getMetaData:   function (key) { return %3[key]; } }";
    response->write(res.arg(QString(spine.toJson()), QString(contents.toJson()),
                            QString(metadata.toJson())));
    response->end();
}

QVariantMap PDFReader::getCoverInfo(int thumbsize, int fullsize)
{
    QVariantMap res;
    if (!this->pdf)
        return res;

    res["title"] = this->metadata.contains("title") ? this->metadata["title"] : "ZZZnone";
    res["author"] = this->metadata.contains("author") ? this->metadata["author"] : "";
    res["authorsort"] = "zzznone";
    res["cover"] = "ZZZnone";

    Poppler::Page *page = this->pdf->page(0);
    QImage coverimg = page->renderToImage();
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    coverimg.scaledToWidth(thumbsize, Qt::SmoothTransformation).save(&buffer, "PNG");
    res["cover"] = "data:image/png;base64," + QString(byteArray.toBase64());
    QByteArray byteArrayf;
    QBuffer bufferf(&byteArrayf);
    coverimg.scaledToWidth(fullsize, Qt::SmoothTransformation).save(&bufferf, "PNG");
    res["fullcover"] = "data:image/png;base64," + QString(byteArrayf.toBase64());
    return res;
}
