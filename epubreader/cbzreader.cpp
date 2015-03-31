/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "cbzreader.h"
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

CBZReader::CBZReader(QObject *parent) :
    QObject(parent)
{
    this->zip = NULL;
}

bool CBZReader::load(const QString &filename)
{
    if (this->zip != NULL) {
        delete this->zip;
        this->zip = NULL;
    }
    this->_hash = "";
    this->spine.clear();

    this->zip = new QuaZip(filename);
    if (!this->zip->open(QuaZip::mdUnzip)) {
        delete this->zip;
        this->zip = NULL;
        return false;
    }
    if (!this->parse()) {
        delete this->zip;
        this->zip = NULL;
        return false;
    }
    return true;
}

bool CBZReader::parse() {
    QList<QuaZipFileInfo> fileList = this->zip->getFileInfoList();
    foreach (const QuaZipFileInfo info, fileList) {
        if (info.uncompressedSize > 0)
            this->spine.append(info.name);
    }
    return true;
}

QString CBZReader::hash() {
    if (this->_hash != "")
        return this->_hash;

    if (!this->zip || !this->zip->isOpen())
        return this->_hash;

    QByteArray CRCarray;
    QDataStream CRCstream(&CRCarray, QIODevice::WriteOnly);
    QList<QuaZipFileInfo> fileList = this->zip->getFileInfoList();
    foreach (const QuaZipFileInfo info, fileList) {
        CRCstream << info.crc;
    }
    this->_hash = QCryptographicHash::hash(CRCarray, QCryptographicHash::Md5).toHex();
    return this->_hash;
}

QString CBZReader::title() {
    return "";
}

void CBZReader::serveComponent(const QString &filename, QHttpResponse *response)
{
    if (!this->zip || !this->zip->isOpen()) {
        response->writeHead(500);
        response->end("Epub file not open for reading");
        return;
    }

    this->zip->setCurrentFile(filename);
    QuaZipFile zfile(this->zip);
    if (!zfile.open(QIODevice::ReadOnly)) {
        response->writeHead(404);
        response->end("Could not find \"" + filename + "\" in epub file");
        return;
    }

    response->setHeader("Content-Type", guessMimeType(filename));
    response->writeHead(200);
    // Important -- use write instead of end, so binary data doesn't get messed up!
    response->write(zfile.readAll());
    response->end();
    zfile.close();
}

QVariantList CBZReader::getContents()
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

void CBZReader::serveBookData(QHttpResponse *response)
{
    if (!this->zip || !this->zip->isOpen()) {
        response->writeHead(500);
        response->end("Epub file not open for reading");
        return;
    }

    response->setHeader("Content-Type", guessMimeType("js"));
    response->writeHead(200);
    QJsonDocument spine(QJsonArray::fromStringList(this->spine));
    QJsonDocument contents(QJsonArray::fromVariantList(this->getContents()));
    QString res = "var bookData = {" \
            "getComponents: function () { return %1; }, " \
            "getContents:   function () { return %2; }, " \
            "getComponent:  function (component) { return " \
            "\"<img style='display: block; margin: auto; max-height: 100% !important' src='\"" \
            "+ component.replace(/\"/g, \"&#34;\").replace(/'/g, \"&#39;\") + \"' />\"; }, " \
            "getMetaData:   function (key) { return ''; } }";
    response->write(res.arg(QString(spine.toJson()), QString(contents.toJson())));
    response->end();
}

QVariantMap CBZReader::getCoverInfo(int thumbsize, int fullsize)
{
    QVariantMap res;
    if (!this->zip || !this->zip->isOpen())
        return res;

    res["title"] = "ZZZnone";
    res["author"] = "";
    res["authorsort"] = "zzznone";
    res["cover"] = "ZZZnone";

    this->zip->setCurrentFile(this->spine[0]);
    QuaZipFile zfile(this->zip);
    if (!zfile.open(QIODevice::ReadOnly))
        return res;

    QImage coverimg;
    if (!coverimg.loadFromData(zfile.readAll())) {
        zfile.close();
        return res;
    }
    zfile.close();
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
