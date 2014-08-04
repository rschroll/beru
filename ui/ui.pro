TEMPLATE = lib

# Disable library building code.
# See http://entrenchant.blogspot.com/2009/08/using-qmake-without-build-target.html
NOOP = true
QMAKE_CC = $$NOOP
QMAKE_CXX = $$NOOP
QMAKE_LINK = $$NOOP
QMAKE_LN_SHLIB = $$NOOP

IMG_SOURCES = images/stainedpaper_tiled.jpg

OTHER_FILES += main.qml BookPage.qml LocalBooks.qml Server.qml BookSources.qml BrowserPage.qml\
    DefaultCover.qml components/StylableOptionSelectorDelegate.qml components/TitlelessDialog.qml\
    qmlmessaging.js historystack.js

# Define a new "compiler"
encoder.output = Textures.qml
encoder.commands = sh ./encoder.sh ${QMAKE_FILE_NAME} > ${QMAKE_FILE_OUT}
encoder.input = IMG_SOURCES

QMAKE_EXTRA_COMPILERS += encoder
