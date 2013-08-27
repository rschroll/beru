---
layout: post
title: Iterating over a FolderListModel
---
Up to now, Beru has just listed whatever files it can find in `~/Books`.  But it'd be better to store information about these files in a database, where we can also store titles, authors, and cover images.  But we still want to automatically includes the files in `~/Books`, so we need a way of going through all those files.

If you remember the [previous episode]({{ site.baseurl }}{% post_url 2013-08-15-listing-files-in-qml %}), you'll recall that we used a `FolderListModel` to access the list of files.  In QML, a `ListModel` is the thing that holds the data that's going to be displayed in a list.  Usually, you can go through its elements programatically:


{% highlight qml %}
for (var i=0; i<model.count; i++) {
    var item = model.get(i)
    // Do something
}
{% endhighlight %}

But this doesn't work with a `FolderListModel`&mdash;it doesn't have a `count` attribute.  Luckily, the [music app](https://launchpad.net/music-app) people have a solution: Make a `Repeater` using this model, create an `Item` for each entry, and run code in its `Component.onCompleted`.  Here's the basic idea.

{% highlight qml %}
FolderListModel {
    id: folderModel
    // various settings
}

Repeater {
    model: folderModel
    
    Component {
        Item {
            Component.onCompleted: // Do something
        }
    }
}
{% endhighlight %}

It's clever, but I do wonder why (or if) it's necessary.
