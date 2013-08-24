TEMPLATE = lib
CONFIG += plugin

TARGET = epubreaderplugin
DESTDIR = ../Epub

QT       += xml qml
QT       -= gui

#LIBS += -Lquazip -lquazip
#LIBS += -lquazip
#LIBS += quazip/libquazip.so.1

#LIBS += ../HttpServer/libqhttpserver.so

INCLUDEPATH += quazip ../qhttpserver ../qhttpserver/http-parser

SOURCES += epubreader.cpp epubreaderplugin.cpp quazip/*.cpp quazip/unzip.c quazip/zip.c \
    ../qhttpserver/q*.cpp ../qhttpserver/http-parser/http_parser.c ../qhttpserver/http-parser/url_parser.c

HEADERS += epubreader.h epubreaderplugin.h quazip/*.h \
    ../qhttpserver/q*.h ../qhttpserver/http-parser/http_parser.h

OBJECTS_DIR = tmp
MOC_DIR = tmp
