---
layout: post
title: Listing files in QML
---
From [previous]({{ site.baseurl }}{% post_url 2013-08-12-opening-a-file-in-qml %}) [experiences]({{ site.baseurl }}{% post_url 2013-08-14-reading-files-with-a-c++-plugin-in-qml %}), we might expect a hard road trying to get a list of files in a directory.  And as expected, there's no way to do this directly in QML.

Luckily, the fine folks over at Nemo Mobile have created [FolderListModel](https://github.com/nemomobile/nemo-qml-plugin-folderlistmodel), with provides a ListModel populated with entries corresponding to the files in a given folder.  The core [music app](https://launchpad.net/music-app) uses this to get a list of songs for it to play, so I figure it's somewhat official.


The plugin is not in the Ubuntu SDK, for some reason, so you have to install it separately.  Fortunately, it's in the archives, so you can get it as quickly as you can say `apt-get install qtdeclarative5-nemo-qml-plugin-folderlistmodel`.  Perhaps faster, depending on your internet connection.

Once it's installed, you can use it like so:

{% highlight qml %}
import Ubuntu.Components.ListItems 0.1
import org.nemomobile.folderlistmodel 1.0

ListView {

    FolderListModel {
        id: folderScannerModel
        isRecursive: true
        showDirectories: true
        filterDirectories: false
        path: homePath() + "/Books"
        nameFilters: ["*.epub"] // file types supported.
    }

    model: folderScannerModel

    delegate: Subtitled {
        text: model.fileName
        subText: model.filePath
        onClicked: // Do something
    }
}
{% endhighlight %}

The whole system of ListViews/Models/delegates is new to me, so I'm not entirely sure I grok it.  As I understand it, the ListView is the thing that appears on the screen, the ListModel is the data that you want listed, and the delegate tells the view how to format the data from the model.  In this case, the delegate is `Subtitled`, one of the [ListItems](http://developer.ubuntu.com/api/devel/ubuntu-13.10/qml/ui-toolkit/overview-ubuntu-sdk.html#list-items) provided by the Ubuntu SDK, and we're telling it to put the file name as the main text and the path to the file as the subtitle.

The options set in the `FolderListModel` are ones copied from the music app.  I haven't explored them in any detail, and you can probably guess as well as I what they do.  I haven't found any documentation for this, so I guess we'll have to read the source to find out more.

In the `onClicked` handler in the delegate, you can react to the user choosing that file.  Remember that all you have is the file name and path; you don't have the some file object to manipulate.  If you want to ready this file, you still have to jump through [these]({{ site.baseurl }}{% post_url 2013-08-12-opening-a-file-in-qml %}) [hoops]({{ site.baseurl }}{% post_url 2013-08-14-reading-files-with-a-c++-plugin-in-qml %}).
