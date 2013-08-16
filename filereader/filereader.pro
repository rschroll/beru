TEMPLATE = lib
CONFIG += plugin
QT += qml quick

DESTDIR = ../File
TARGET = filereaderplugin

OBJECTS_DIR = tmp
MOC_DIR = tmp

HEADERS += filereader.h filereaderplugin.h

SOURCES += filereader.cpp filereaderplugin.cpp
