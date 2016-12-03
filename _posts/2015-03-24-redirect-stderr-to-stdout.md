---
layout: post
tags: [ruby, shell]
title: Redirect STDERR to STDOUT
---
If you ever executed a shell command from a Ruby code like this:

{% highlight ruby %}
result = `identify photo.jpg` # => photo.jpg JPEG 128x128 128x128+0+0 8-bit DirectClass 1.51KB 0.000u 0:00.000
raise Error unless $?.success?
{% endhighlight %}

Well, you're doing it wrong! Okay, okay. It will work but you are hurting
yourself (or perhaps any developer that will maintain such code later).

Most of well written shell commands provides useful information whenever
something goes wrong. For example:

{% highlight bash %}
$ identify foo.pdf
identify.im6: unable to open image `foo.pdf': No such file or directory @ error/blob.c/OpenBlob/2638.
{% endhighlight %}

{% highlight bash %}
$ identify sample.doc
identify.im6: no decode delegate for this image format `sample.doc' @ error/constitute.c/ReadImage/544.
{% endhighlight %}

You can immediately tell what's the problem when executing those commands.
You may be thinking that this message will be stored in a `result` variable from
the example above, but this is not true:

{% highlight bash %}
$ identify sample.doc 2>/dev/null
$
{% endhighlight %}

No output at all! The message instead of standard output was written to
standard error. Executing shell command using backticks in Ruby returns whatever was
written into a STDOUT thus all the helpful error messages are gone. That
leads you to hard to find problems.

You can easily redirect standard error into a standard output in bash by
appending ``2>&1`` to the executed command. So proper way of wrapping bash
commands in Ruby should be:


{% highlight ruby %}
result = `identify photo.jpg 2>&1`
raise Error, result unless $?.success?
{% endhighlight %}

That way the exception raised will contain the error message which
command put into to the STDERR. So make yourself (and other developers) a favor
and as a rule of thumb redirect STDERR to STDOUT in wrapped shell commands.

## TL;DR

It is even more important when the command you've executing seems to be ignoring
UNIX practices and returns always 0 as a exist status code. That happened to me
lately and because of lack of redirection the command was always assumed to be executing
successfully (despite of the fact that device was unplugged and tool was logging errors
to STDERR).
