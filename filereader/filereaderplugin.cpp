#include "filereaderplugin.h"
#include "filereader.h"
#include <qqml.h>

void FileReaderPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<FileReader>(uri, 1, 0, "FileReader");
}
