---
layout: page
title: Application Confinement
---

If you installed Beru from the [Ubuntu Software Store]({{ site.baseurl }}/install.html#store), it runs under [application confinement](http://mdeslaur.blogspot.com/2013/12/ubuntu-touch-and-user-privacy.html), which restricts the resources which Beru can use.  One of these restrictions is that Beru can only read and write to a very specific directory in your home folder: `~/.local/share/com.ubuntu.developers.rschroll.beru/`.  If you want to read books stored in another location in your home directory, this is rather frustrating.

Below, we present several ways to work around this restriction.  You only need one of them, so pick the one that seems easiest for you.

Changing the restrictions
-------------------------
Click packages, like those from the software store, come with a file that describes the restrictions under which the software runs.  You can modify that file to grant Beru access to the files in your home directory.  In the directory `/opt/click.ubuntu.com/com.ubuntu.developer.rschroll.beru/current/apparmor/`, rename the file `beru.access.json` to `beru.json`.  (You will have to do this as root.)  Note that this will overwrite the existing `beru.json` file; move that somewhere else first if you might want to revert this change.  Then run, as root, `aa-clickhook -f` to register the new restrictions.

Beru will still use the old location to look for and save Epub files.  To change this to a more convenient location, select the *Settings* item on the toolbar of the *Library* page and enter the location of the directory you wish to use for this purpose.  (May I suggest `Books`?)  You may select an existing directory or create a new one.  Files in the old directory will not be moved, but you will still be able to read them in Beru.

You may need to repeat this first step after upgrading Beru, but the setting made in Beru will persist.

Please note that this change gives Beru read and write access to everything in your home directory.  It will only use this access to read existing Epub files and save new Epub files that you download from the Web.

Installing an unrestricted version
----------------------------------
On this website, we offer [click packages]({{ site.baseurl }}/install.html#click) identical to those from the software store, except without the restrictions on accessing files.  These can be installed over those from the software store.

As in the above case, the default location for your Epubs will not change after installing the new version.  From the *Library* page, select *Settings* on the toolbar to choose or create a directory for your Epub files.  This does not affect your existing files.

If you install a newer version from the software store, the restrictions will be reinstated.  Instead, download and install the new click package from the [install page]({{ site.baseurl }}/install.html#click).

Using a symlink
---------------
If you don't wish to grant Beru unfettered access to your home directory, you can still get more convenient access to your Epub files by creating a symbolic link from your desired directory name to `~/.local/share/com.ubuntu.developers.rschroll.beru/Books/`  That is, if you wish your books to be accessible in `~/Books/`, run
{% highlight bash %}
ln -s ~/.local/share/com.ubuntu.developers.rschroll.beru/Books/ ~/Books
{% endhighlight %}
Note that this order is important&mdash;you cannot make the confinement directory a symlink to a directory outside of the silo, as AppArmor will block the access.  This means that you cannot share books between several readers using this method.
