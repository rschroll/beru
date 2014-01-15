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
Download a click package for your [touch device (arm)]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.9.7_armhf.click) or [desktop (amd64)]({{ site.baseurl }}/assets/com.ubuntu.developer.rschroll.beru_0.9.7_amd64.click).  Allegedly you can install it with
{% highlight bash %}
sudo pkcon install-local *.click
{% endhighlight %}
I've never gotten that to work, though, so I install with
{% highlight bash %}
sudo click install --force-missing-framework --user=$USER *.click
{% endhighlight %}

## <a name="ppa">PPA</a>
Beru is available in [ppa:rschroll/beru](https://launchpad.net/~rschroll/+archive/beru).  Add that to your software sources, and you should be able to install Beru with your favorite package manager.

If you're on Precise or Quantal, you'll also need to add [ppa:ubuntu-sdk-team/ppa](https://launchpad.net/~ubuntu-sdk-team/+archive/ppa).  It's probably not a bad idea to add that even if you're running a more recent version, to ensure that you have an up-to-date version of the Ubuntu SDK.

## <a name="git">Git</a>
You can browse the source on [GitHub](https://github.com/rschroll/beru) or get it for yourself with
{% highlight bash %}
git clone https://github.com/rschroll/beru.git
{% endhighlight %}
The [README](https://github.com/rschroll/beru/blob/master/README.md) gives instructions on building.

## On version numbers
Versions ending in an even number are subject to [confinement restrictions on file access]({{ site.baseurl }}/confinement.html); versions ending in an odd number are not.  Otherwise, *a.b.(2n)* and *a.b.(2n+1)* are identical.  The former is found only in the Software Store.
