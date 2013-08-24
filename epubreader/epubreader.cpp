/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "epubreader.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include "quazip/quazip.h"
#include "quazip/quazipfile.h"
#include "../qhttpserver/qhttpresponse.h"

EpubReader::EpubReader(QObject *parent) :
    QObject(parent)
{
}

bool EpubReader::load(const QString &filename)
{
    if (this->zip != NULL)
        delete this->zip;
    this->navhref = "";
    this->ncxhref = "";
    this->spine.clear();
    this->metadata.clear();

    this->zip = new QuaZip(filename);
    if (!this->zip->open(QuaZip::mdUnzip)) {
        delete this->zip;
        return false;
    }
    if (!this->parseOPF()) {
        delete this->zip;
        return false;
    }
    return true;
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
        return NULL;
    }
    return doc;
}

void EpubReader::serveComponent(const QString &filename, QHttpResponse *response)
{
    if (!this->zip || !this->zip->isOpen()) {
        response->writeHead(500);
        response->end("Epub file not open for reading");
    }

    this->zip->setCurrentFile(filename);
    QuaZipFile zfile(this->zip);
    if (!zfile.open(QIODevice::ReadOnly)) {
        response->writeHead(404);
        response->end("Could not find \"" + filename + "\" in epub file");
    }

    response->writeHead(200);
    // Important -- use write instead of end, so binary data doesn't get messed up!
    response->write(zfile.readAll());
    response->end();
}

bool EpubReader::parseOPF()
{
    // Get the container.xml file.
    QDomDocument* container = this->getFileAsDom("META-INF/container.xml");
    if (container == NULL)
        return false;

    // Find out where the OPF file lives.
    QString contentsfn, contentsdir;
    QDomNodeList nodes = container->elementsByTagName("rootfile");
    for (int i=0; i<nodes.length(); i++) {
        QDomElement element = nodes.item(i).toElement();
        if (element.attribute("media-type") == "application/oebps-package+xml") {
            contentsfn = element.attribute("full-path");
            break;
        }
    }

    int pathlen = contentsfn.lastIndexOf('/');
    if (pathlen > 0)
        contentsdir = contentsfn.left(pathlen+1);
    else
        contentsdir = "";

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
        idmap[item.attribute("id")] = contentsdir + item.attribute("href");
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
            this->metadata[item.nodeName().split(":").last()] = item.firstChild().nodeValue();
        }
    }

    // If this is an Epub3, we've already found the table of contents.  If not,
    // we'll get the Epub2 table of contents.
    if (this->navhref == "")
        this->ncxhref = idmap[spine.attribute("toc")];

    return true;
}

QVariantList EpubReader::getContents() {
    if (this->navhref != "")
        return this->parseNav();
    return this->parseNCX();
}

QVariantList EpubReader::parseNav() {
    int pathlen = this->navhref.lastIndexOf('/');
    QString navdir;
    if (pathlen > 0)
        navdir = this->navhref.left(pathlen+1);
    else
        navdir = "";

    QDomDocument* navdoc = this->getFileAsDom(this->navhref);
    QDomNodeList nodes = navdoc->elementsByTagName("nav");
    for (int i=0; i<nodes.length(); i++) {
        QDomElement nav = nodes.item(i).toElement();
        if (nav.attribute("epub:type") == "toc") {
            QDomNodeList ols = nav.elementsByTagName("ol");
            if (!ols.isEmpty())
                return this->parseNavList(ols.item(0).toElement(), navdir);
        }
    }
    return QVariantList();
}

QVariantList EpubReader::parseNavList(QDomElement element, QString navdir)
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
            entry["src"] = navdir + link.attribute("href");
            QDomNodeList olist = item.elementsByTagName("ol");
            if (!olist.isEmpty())
                entry["children"] = this->parseNavList(olist.item(0).toElement(), navdir);
            children.append(entry);
        }
    }
    return children;
}

QVariantList EpubReader::parseNCX()
{
    int pathlen = this->ncxhref.lastIndexOf('/');
    QString navdir;
    if (pathlen > 0)
        navdir = this->ncxhref.left(pathlen+1);
    else
        navdir = "";

    QDomDocument* ncxdoc = this->getFileAsDom(this->ncxhref);
    QDomNodeList nodes = ncxdoc->elementsByTagName("navMap");
    if (nodes.isEmpty())
        return QVariantList();
    return this->parseNCXChildren(nodes.item(0).toElement(), navdir);
}

QVariantList EpubReader::parseNCXChildren(QDomElement element, QString navdir)
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
                entry["src"] = navdir + contents.item(0).toElement().attribute("src");
            QVariantList child_nav = this->parseNCXChildren(node, navdir);
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
    }

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
