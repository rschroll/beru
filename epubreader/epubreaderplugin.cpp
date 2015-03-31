/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

#include "epubreaderplugin.h"
#include "epubreader.h"
#include "cbzreader.h"
#include "pdfreader.h"
#include <qqml.h>

void EpubReaderPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<EpubReader>(uri, 1, 0, "EpubReader");
    qmlRegisterType<CBZReader>(uri, 1, 0, "CBZReader");
    qmlRegisterType<PDFReader>(uri, 1, 0, "PDFReader");
}
