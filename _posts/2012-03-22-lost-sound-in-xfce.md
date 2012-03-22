---
layout: post
tags: [linux, xfce]
---
Lately I've lost sound on my Xubuntu. There was no particular reason
for this. Sound was working and suddenly it was gone. It turned out
that for some reason sound wasn't sent to the analog output device but to the
HDMI, while my laptop has 2 output devices. The solution
was to use `pavucontrol` tool which is able to switch default output
device (while default Xfce mixer cannot do this).

I've digged a little bit more in this regard. To check how many
devices system detects `aplay` command may be used:

{% highlight bash %}
$ aplay -l
**** List of PLAYBACK Hardware Devices ****
card 0: PCH [HDA Intel PCH], device 0: STAC92xx Analog [STAC92xx Analog]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: NVidia [HDA NVidia], device 3: HDMI 0 [HDMI 0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
{% endhighlight %}

Output proves that both output devices were correctly detected on my machine. To
check which one is currently used as default output device we need to
look into `~/.pulse` directory, and view content of `*-default-sink` file:

{% highlight bash %}
$ cat ~/.pulse/638ad76668415c922af89aab00000006-default-sink 
alsa_output.pci-0000_00_1b.0.analog-stereo
{% endhighlight %}

If instead of `analog-stereo` device the HDMI will be used you will
know that sound is gone because it is send to the wrong device.
