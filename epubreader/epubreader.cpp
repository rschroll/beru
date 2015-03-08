/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "epubreader.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QtGui/QImage>
#include <QBuffer>
#include <QDir>
#include <QCryptographicHash>
#include <QDebug>
#include "quazip/quazip.h"
#include "quazip/quazipfile.h"
#include "../qhttpserver/qhttpresponse.h"
#include "../mimetype/mimetype.h"

QString resolveRelativePath(QString relto, QString path)
{
    int reldirlen = relto.lastIndexOf('/');
    QString reldir = (reldirlen > 0) ? relto.left(reldirlen+1) : "";
    return QDir::cleanPath(reldir + path);
}

EpubReader::EpubReader(QObject *parent) :
    QObject(parent)
{
    this->zip = NULL;
}

bool EpubReader::load(const QString &filename)
{
    if (this->zip != NULL) {
        delete this->zip;
        this->zip = NULL;
    }
    this->_hash = "";
    this->navhref = "";
    this->ncxhref = "";
    this->coverhtml = "";
    this->spine.clear();
    this->metadata.clear();
    this->sortmetadata.clear();

    this->zip = new QuaZip(filename);
    if (!this->zip->open(QuaZip::mdUnzip)) {
        delete this->zip;
        this->zip = NULL;
        return false;
    }
    if (!this->parseOPF()) {
        delete this->zip;
        this->zip = NULL;
        return false;
    }
    return true;
}

QString EpubReader::hash() {
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

QString EpubReader::title() {
    return this->metadata.contains("title") ? this->metadata["title"].toString() : "";
}

QDomDocument* EpubReader::getFileAsDom(const QString &filename)
{
    if (!this->zip || !this->zip->isOpen())
        return NULL;

    this->zip->setCurrentFile(filename);
    QuaZipFile zfile(this->zip);
    if (!zfile.open(QIODevice::ReadOnly))
        return NULL;

    QDomDocument* doc = new QDomDocument();
    if (!doc->setContent(&zfile)) {
        delete doc;
        zfile.close();
        return NULL;
    }
    zfile.close();
    return doc;
}

void EpubReader::serveComponent(const QString &filename, QHttpResponse *response)
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

bool EpubReader::parseOPF()
{
    // Get the container.xml file.
    QDomDocument* container = this->getFileAsDom("META-INF/container.xml");
    if (container == NULL)
        return false;

    // Find out where the OPF file lives.
    QString contentsfn;
    QDomNodeList nodes = container->elementsByTagName("rootfile");
    for (int i=0; i<nodes.length(); i++) {
        QDomElement element = nodes.item(i).toElement();
        if (element.attribute("media-type") == "application/oebps-package+xml") {
            contentsfn = element.attribute("full-path");
            break;
        }
    }

    // Open the OPF file.
    QDomDocument* contents = this->getFileAsDom(contentsfn);
    if (contents == NULL)
        return false;

    // Read the manifest.
    nodes = contents->elementsByTagName("manifest");
    if (nodes.isEmpty())
        return false;
    QDomElement manifest = nodes.item(0).toElement();
    QHash<QString, QString> idmap;
    nodes = manifest.elementsByTagName("item");
    for (int i=0; i<nodes.length(); i++) {
        QDomElement item = nodes.item(i).toElement();
        idmap[item.attribute("id")] = resolveRelativePath(contentsfn, item.attribute("href"));
        if (item.attribute("properties").split(" ").contains("nav"))
            this->navhref = idmap[item.attribute("id")];
    }

    // Read the spine.
    nodes = contents->elementsByTagName("spine");
    if (nodes.isEmpty())
        return false;
    QDomElement spine = nodes.item(0).toElement();
    nodes = spine.elementsByTagName("itemref");
    for (int i=0; i<nodes.length(); i++) {
        QDomElement item = nodes.item(i).toElement();
        this->spine.append(idmap[item.attribute("idref")]);
    }

    // Read the metadata.
    nodes = contents->elementsByTagName("metadata");
    if (nodes.isEmpty())
        return false;
    QDomElement metadata = nodes.item(0).toElement();
    nodes = metadata.childNodes();
    for (int i=0; i<nodes.length(); i++) {
        QDomElement item = nodes.item(i).toElement();
        if (!item.isNull() && !item.firstChild().isNull()) {
            QString name = item.nodeName().split(":").last();
            this->metadata[name] = item.firstChild().nodeValue();
            // This should work, but doesn't:
            //QString fileas = item.attributeNS("http://www.idpf.org/2007/opf", "file-as");
            QString fileas = item.attribute("opf:file-as");
            if (!fileas.isEmpty())
                this->sortmetadata[name] = fileas;
        }
    }
    // And construct the components weight list, based on file size
    if (!this->metadata.contains("componentWeights")) {
        quint32 totalSize = 0;
        QVariantList componentWeights;
        foreach(const QString filename, this->spine) {
            this->zip->setCurrentFile(filename);
            QuaZipFileInfo info;
            this->zip->getCurrentFileInfo(&info);
            totalSize += info.uncompressedSize;
        }
        foreach(const QString filename, this->spine) {
            this->zip->setCurrentFile(filename);
            QuaZipFileInfo info;
            this->zip->getCurrentFileInfo(&info);
            QVariant thisComponentWeight;
            thisComponentWeight = (float)info.uncompressedSize / (float)totalSize;
            componentWeights.append(thisComponentWeight.toDouble());
        }
        this->metadata["componentWeights"] = componentWeights;
    }
    // If this is an Epub3, we've already found the table of contents.  If not,
    // we'll get the Epub2 table of contents.
    if (this->navhref == "")
        this->ncxhref = idmap[spine.attribute("toc")];

    // Look for the HTML file that contains the cover image
    nodes = contents->elementsByTagName("guide");
    if (!nodes.isEmpty()) {
        QDomElement guide = nodes.item(0).toElement();
        nodes = guide.childNodes();
        for (int i=0; i<nodes.length(); i++) {
            QDomElement reference = nodes.item(i).toElement();
            if (!reference.isNull() && reference.attribute("type") == "cover") {
                this->coverhtml = resolveRelativePath(contentsfn, reference.attribute("href"));
                break;
            }
        }
    }
    // If it's not in the guide, guess the first element of the spine
    if (this->coverhtml == "")
        this->coverhtml = this->spine.first();

    return true;
}

QVariantList EpubReader::getContents()
{
    QVariantList res = (this->navhref != "") ? this->parseNav() : this->parseNCX();
    emit contentsReady(res);
    return res;
}

QVariantList EpubReader::parseNav()
{
    QDomDocument* navdoc = this->getFileAsDom(this->navhref);
    QDomNodeList nodes = navdoc->elementsByTagName("nav");
    for (int i=0; i<nodes.length(); i++) {
        QDomElement nav = nodes.item(i).toElement();
        if (nav.attribute("epub:type") == "toc") {
            QDomNodeList ols = nav.elementsByTagName("ol");
            if (!ols.isEmpty())
                return this->parseNavList(ols.item(0).toElement());
        }
    }
    return QVariantList();
}

QVariantList EpubReader::parseNavList(QDomElement element)
{
    QVariantList children;
    QDomNodeList nodes = element.childNodes();
    for (int i=0; i<nodes.length(); i++) {
        QDomElement item = nodes.item(i).toElement();
        if (!item.isNull() && item.nodeName() == "li") {
            QDomNodeList links = item.elementsByTagName("a");
            if (links.isEmpty())
                continue;
            QDomElement link = links.item(0).toElement();
            QVariantMap entry;
            entry["title"] = link.firstChild().nodeValue();
            entry["src"] = resolveRelativePath(this->navhref, link.attribute("href"));
            QDomNodeList olist = item.elementsByTagName("ol");
            if (!olist.isEmpty())
                entry["children"] = this->parseNavList(olist.item(0).toElement());
            children.append(entry);
        }
    }
    return children;
}

QVariantList EpubReader::parseNCX()
{
    QDomDocument* ncxdoc = this->getFileAsDom(this->ncxhref);
    QDomNodeList nodes = ncxdoc->elementsByTagName("navMap");
    if (nodes.isEmpty())
        return QVariantList();
    return this->parseNCXChildren(nodes.item(0).toElement());
}

QVariantList EpubReader::parseNCXChildren(QDomElement element)
{
    QVariantList children;
    QDomNodeList nodes = element.childNodes();
    for (int i=0; i<nodes.length(); i++) {
        QDomElement node = nodes.item(i).toElement();
        if (!node.isNull() && node.nodeName() == "navPoint") {
            QVariantMap entry;
            QDomNodeList labels = node.elementsByTagName("text");
            if (!labels.isEmpty())
                entry["title"] = labels.item(0).firstChild().nodeValue();
            QDomNodeList contents = node.elementsByTagName("content");
            if (!contents.isEmpty())
                entry["src"] = resolveRelativePath(this->ncxhref,
                                                   contents.item(0).toElement().attribute("src"));
            QVariantList child_nav = this->parseNCXChildren(node);
            if (!child_nav.isEmpty())
                entry["children"] = child_nav;
            children.append(entry);
        }
    }
    return children;
}

void EpubReader::serveBookData(QHttpResponse *response)
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
    QJsonDocument metadata(QJsonObject::fromVariantMap(this->metadata));
    QString res = "var bookData = {" \
            "getComponents: function () { return %1; }, " \
            "getContents:   function () { return %2; }, " \
            "getComponent:  function (component) { return { url: component }; }, " \
            "getMetaData:   function (key) { return %3[key]; } }";
    response->write(res.arg(QString(spine.toJson()), QString(contents.toJson()),
                            QString(metadata.toJson())));
    response->end();
}

QVariantMap EpubReader::getCoverInfo(int thumbsize, int fullsize)
{
    QVariantMap res;
    if (!this->zip || !this->zip->isOpen())
        return res;

    res["title"] = this->metadata.contains("title") ? this->metadata["title"] : "ZZZnone";
    res["author"] = this->metadata.contains("creator") ? this->metadata["creator"] : "";
    res["authorsort"] = this->sortmetadata.contains("creator") ? this->sortmetadata["creator"] : "zzznone";
    res["cover"] = "ZZZnone";

    QDomDocument* coverdoc = this->getFileAsDom(this->coverhtml);
    if (coverdoc == NULL)
        return res;

    QString coversrc;
    QDomNodeList images = coverdoc->elementsByTagName("img");
    if (!images.isEmpty()) {
        coversrc = images.item(0).toElement().attribute("src");
    } else {
        // Image inside a SVG element
        images = coverdoc->elementsByTagName("image");
        if (!images.isEmpty())
            coversrc = images.item(0).toElement().attribute("xlink:href");
    }
    if (coversrc.isEmpty())
        return res;

    this->zip->setCurrentFile(resolveRelativePath(this->coverhtml, coversrc));
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
