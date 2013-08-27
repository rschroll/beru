Basic Epub Reader for Ubuntu
============================
Beru is an epub reader for Ubuntu Touch.  Right now, it runs and
generally behaves itself.  But it is still very much alpha software
and rough edges certainly exists.  Watch the progress at
http://rschroll.github.io/beru/.

Building
--------
You will need the [Ubuntu SDK][1].  Additionally, you need the Nemo
Mobile FolderListModel, which is in the Ubuntu repositories as
`qtdeclarative5-nemo-qml-plugin-folderlistmodel`. Then do
```
$ qmake
$ make
```
Hopefully, everything will work.

Running
-------
Launch Beru with the shell script `beru`.

Beru keeps a library of epub files.  On every start, the folder
`~/Books` is searched and all epubs in it are included in the
library.  You may also pass a epub file to `beru` as an argument.
This will open the file and add it to your library.

The Library is stored in a local database.  While I won't be
cavalier about changing the database format, it may happen.  If
you're getting database errors after upgrading, delete the database
and reload your files.  The database is one of the ones in
`~/.local/share/Qt Project/QtQmlViewer/QML/OfflineStorage/Databases`;
read the `.ini` files to find the one with `Name=BeruLocalBooks`.

Known Problems
--------------
Everything is ugly and clunky.

Sometimes the display gets messed up, resulting in two partial
columns of text visible.  A repeatable test case would be helpful in
fixing this.

Please [submit bugs][2] that you find!

[1]: http://developer.ubuntu.com/get-started/#step-get-toolkit "Ubuntu SDK"
[2]: https://github.com/rschroll/beru/issues "Bug tracker"
