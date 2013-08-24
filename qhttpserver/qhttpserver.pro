TEMPLATE = lib
CONFIG += plugin

TARGET = qhttpserver
VERSION = 0.1.0

QT += network
QT += qml
QT -= gui

CONFIG += dll debug
DEFINES += QT_NO_DEBUG_OUTPUT

INCLUDEPATH += http-parser

PRIVATE_HEADERS += http-parser/http_parser.h qhttpconnection.h

PUBLIC_HEADERS += qhttpserver.h qhttprequest.h qhttpresponse.h httpserverplugin.h

HEADERS = $$PRIVATE_HEADERS $$PUBLIC_HEADERS
SOURCES = *.cpp http-parser/http_parser.c

OBJECTS_DIR = tmp
MOC_DIR = tmp
DESTDIR = ../HttpServer
