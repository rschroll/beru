Basic Epub Reader for Ubuntu
============================
Beru will be an epub reader for Ubuntu Touch.  Right now, it runs,
but it's not particularly pretty or crash-free.  Watch the progress
at http://rschroll.github.io/beru/ to see when it becomes useable.

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
Launch Beru with the shell script `beru`.  Right now, it must be run
from the same directory its in; this is one of many things to fix.

Beru lists and lets you read books in `~/Books`.  If that directory
doesn't exist, Beru opens a hole in the spacetime continuum.  This
is another thing to fix.

Known Problems
--------------
Certain files in certain Epubs cause Beru to hang while trying to
read them.

Everything is ugly and clunky.

Please [submit bugs][2] that you find!

[1]: http://developer.ubuntu.com/get-started/#step-get-toolkit "Ubuntu SDK"
[2]: https://github.com/rschroll/beru/issues "Bug tracker"
