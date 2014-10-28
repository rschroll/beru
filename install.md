---
layout: page
title: Installation Methods
---

There are a number of ways to install Beru.  My recommendations are as follows:

* On a touch device, if you don't care where books are stored: [Ubuntu Software Store](#store)
* On a touch device, if you want to control where books are stored: [Click package](#click)
* On the desktop: [PPA](#ppa)
* For development: [Git](#git)

## <a name="store">Ubuntu Software Store</a>
Beru is available in the Software Store for Ubuntu Touch.  (This is different from the [Software Center](https://apps.ubuntu.com/cat/) and apparently doesn't have a website.)  If you search in your Dash for "Beru", it should come up and be installable with a single click.

Note that this version runs under [application confinement restrictions]({{ site.baseurl }}/confinement.html).

## <a name="click">Click package</a>
Download the click package for your [ARM touch device]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.9.11_armhf.click) and install it with
{% highlight bash %}
sudo pkcon install-local *.click
{% endhighlight %}

## <a name="ppa">PPA</a>
Beru is available in [ppa:rschroll/beru](https://launchpad.net/~rschroll/+archive/beru).  Add that to your software sources, and you should be able to install Beru with your favorite package manager.

You may want to add [ppa:ubuntu-sdk-team/ppa](https://launchpad.net/~ubuntu-sdk-team/+archive/ppa) as well.  This used to ensure that you had an up-to-date version of the Ubuntu SDK.  I'm not quite sure what it does anymore.

## <a name="git">Git</a>
You can browse the source on [GitHub](https://github.com/rschroll/beru) or get it for yourself with
{% highlight bash %}
git clone https://github.com/rschroll/beru.git
{% endhighlight %}
The [README](https://github.com/rschroll/beru/blob/master/README.md) gives instructions on building.

## On version numbers
Versions ending in an even number are subject to [confinement restrictions on file access]({{ site.baseurl }}/confinement.html); versions ending in an odd number are not.  Otherwise, *a.b.(2n)* and *a.b.(2n+1)* are identical.  The former is found only in the Software Store.
