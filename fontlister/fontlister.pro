TEMPLATE = lib
CONFIG += plugin
QT += qml quick

DESTDIR = ../FontList
TARGET = fontlisterplugin

OBJECTS_DIR = tmp
MOC_DIR = tmp

HEADERS += fontlister.h fontlisterplugin.h

SOURCES += fontlister.cpp fontlisterplugin.cpp
