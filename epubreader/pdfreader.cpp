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
    this->pdf->setRenderHint(Poppler::Document::Antialiasing, true);
    this->pdf->setRenderHint(Poppler::Document::TextAntialiasing, true);
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
    foreach (QString k, keys) {
        QString value = this->pdf->info(k);
        if (value != "")
            this->metadata[k.toLower()] = value;
    }
}

QString PDFReader::hash() {
    return this->_hash;
}

void PDFReader::computeHash(const QString &filename) {
    QFile file(filename);
    if (file.open(QFile::ReadOnly)) {
        QCryptographicHash hash(QCryptographicHash::Md5);
        if (hash.addData(&file))
            this->_hash = hash.result().toHex();
    }
}

QString PDFReader::title() {
    return this->metadata.contains("title") ? this->metadata["title"].toString() : "";
}

int PDFReader::height() {
    return this->_height;
}

void PDFReader::setHeight(int value) {
    this->_height = value;
}

int PDFReader::width() {
    return this->_width;
}

void PDFReader::setWidth(int value) {
    this->_width = value;
}

QImage PDFReader::renderPage(int pageNum, int maxWidth, int maxHeight) {
    Poppler::Page *page = this->pdf->page(pageNum);
    QSizeF pageSize = page->pageSizeF();
    qreal pageWidth = pageSize.width(), pageHeight = pageSize.height();
    double res;
    if (maxWidth == -1 && maxHeight == -1) {
        maxWidth = this->_width;
        maxHeight = this->_height;
    }
    if (maxHeight == -1) {
        res = maxWidth / pageWidth * 72;
    } else if (maxWidth == -1) {
        res = maxHeight / pageHeight * 72;
    } else {
        if ((double) pageWidth / pageHeight > maxWidth / maxHeight)
            res = maxWidth / pageWidth * 72;
        else
            res = maxHeight / pageHeight * 72;
    }
    return page->renderToImage(res, res);
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

    QImage pageImage = this->renderPage(pageNum, -1, -1);
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    pageImage.save(&buffer, "PNG");

    response->setHeader("Content-Type", guessMimeType("png"));
    response->writeHead(200);
    // Important -- use write instead of end, so binary data doesn't get messed up!
    response->write(byteArray);
    response->end();
}

QVariantList PDFReader::getContents() {
    QVariantList res;
    QDomDocument *toc = this->pdf->toc();
    if (toc) {
        res = this->parseContents(toc->firstChildElement());
    } else {
        for (int i=0; i<this->spine.length(); i++) {
            QVariantMap entry;
            entry["title"] = "%PAGE% " + QString::number(i + 1);
            entry["src"] = this->spine[i];
            res.append(entry);
        }
    }
    emit contentsReady(res);
    return res;
}

QVariantList PDFReader::parseContents(QDomElement el) {
    QVariantList res;
    while (!el.isNull()) {
        QString title = el.tagName();
        Poppler::LinkDestination *destination = NULL;
        if (el.hasAttribute("Destination")) {
            destination = new Poppler::LinkDestination(el.attribute("Destination"));
        } else if (el.hasAttribute("DestinationName")) {
            destination = this->pdf->linkDestination(el.attribute("DestinationName"));
        }
        if (destination) {
            QVariantMap entry;
            entry["title"] = title;
            entry["src"] = QString::number(destination->pageNumber());
            QDomElement child = el.firstChildElement();
            if (!child.isNull())
                entry["children"] = this->parseContents(child);
            res.append(entry);
        }
        el = el.nextSiblingElement();
    }
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

    QImage coverimg = this->renderPage(0, thumbsize, -1);
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    coverimg.save(&buffer, "PNG");
    res["cover"] = "data:image/png;base64," + QString(byteArray.toBase64());

    QImage coverimgf = this->renderPage(0, fullsize, -1);
    QByteArray byteArrayf;
    QBuffer bufferf(&byteArrayf);
    coverimgf.save(&bufferf, "PNG");
    res["fullcover"] = "data:image/png;base64," + QString(byteArrayf.toBase64());
    return res;
}
