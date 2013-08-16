#ifndef FILEREADERPLUGIN_H
#define FILEREADERPLUGIN_H

#include <QQmlExtensionPlugin>

class FileReaderPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "io.github.rschroll.FileReader")

public:
    void registerTypes(const char *uri);
};

#endif // FILEREADERPLUGIN_H
