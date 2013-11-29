Basic Epub Reader for Ubuntu
============================
Beru is an epub reader for Ubuntu Touch.  It's fair to call it a
beta now, but some rough edges still exist.  Watch the progress at
http://rschroll.github.io/beru/.

Building
--------
You will need the [Ubuntu SDK][1].  Additionally, you need the QML
bindings for U1DB (`qtdeclarative5-u1db1.0` in the Ubuntu
repositories) and the mobile icon set (`ubuntu-mobile-icons`). I
believe all of these will be installed by default on the phone image.

To build, do
```
$ qmake
$ make
```
Note that you need to be using Qt5 for this.  If you also have a Qt4
installation, you may need to use the `-qt` flag to qmake to specify
the version.  (Use `qtchooser --list-versions` to see your options.)

Running
-------
Launch Beru with the shell script `beru`.

Beru keeps a library of epub files.  On every start, the folder
`~/.local/share/com.ubuntu.developer.rschroll.beru/Books` is
searched and all epubs in it are included in the library.  You may
also pass a epub file to `beru` as an argument. This will open the
file and add it to your library.

The Library is stored in a local database.  While I won't be
cavalier about changing the database format, it may happen.  If
you're getting database errors after upgrading, delete the database
and reload your files.  The database is one of the ones in
`~/.local/share/com.ubuntu.developer.rschroll.beru/Databases`;
read the `.ini` files to find the one with `Name=BeruLocalBooks`.

Click Packages
--------------
To build a click package, first follow the build steps above.  Then,
run the script `makeclick.sh` from the top level directory.  This
should give you a click package in that directory.

You can install it on your system with
```
sudo click install --force-missing-framework --user=$USER *.click
```
Note that the click package contains .so files, and is therefore
limited to the architecture on which it was produced.  To produce
click packages for other architectures, you'll need to [cross
compile][2].

Known Problems
--------------
Known bugs are listed on the [issue tracker][3].  If you don't see
your problem listed there, please add it!

[1]: http://developer.ubuntu.com/get-started/#step-get-toolkit "Ubuntu SDK"
[2]: http://notyetthere.org/?p=316#comment-3637 "Michael Zanetti's helpful instructions"
[3]: https://github.com/rschroll/beru/issues "Bug tracker"
