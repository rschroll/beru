/*
 * Copyright 2013 Robert Schroll <rschroll@gmail.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE. 
 */

#include "httpserverplugin.h"
#include "fileserver.h"
#include "qhttpserver.h"
#include "qhttprequest.h"
#include "qhttpresponse.h"
#include <qqml.h>

void HttpServerPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<QHttpServer>(uri, 1, 0, "HttpServer");
    qmlRegisterType<FileServer>(uri, 1, 0, "FileServer");
    qmlRegisterUncreatableType<QHttpRequest>(uri, 1, 0, "HttpRequest", "Do not create HttpRequest directly");
    qmlRegisterUncreatableType<QHttpResponse>(uri, 1, 0, "HttpResponse", "Do not create HttpResponse directly");
}
