TEMPLATE = lib
CONFIG += plugin
QT += qml quick

DESTDIR = ../File
TARGET = filesystemplugin

OBJECTS_DIR = tmp
MOC_DIR = tmp

HEADERS += filesystem.h filesystemplugin.h

SOURCES += filesystem.cpp filesystemplugin.cpp
