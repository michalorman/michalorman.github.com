---
layout: post
---
With the `pdfinfo` tool you can easily check the size of every single
PDF document page by providing the `-l` switch:

{% highlight bash %}
$ pdfinfo -l 5 demo.pdf
...
Page    1 size: 592.56 x 792 pts
Page    1 rot:  0
Page    2 size: 592.56 x 792 pts
Page    2 rot:  270
Page    3 size: 592.56 x 792 pts
Page    3 rot:  0
Page    4 size: 592.56 x 792 pts
Page    4 rot:  270
Page    5 size: 592.56 x 792 pts
Page    5 rot:  0
...
{% endhighlight %}

The problem is that you need to know the document pages count as
a `-l` switch accepts the number of last page to examine. That would
require to execute `pdfinfo` twice: first to get the pages count, second
to get page sizes. However there's a trick to do everything in single
call providing `-1` as the last page number:

{% highlight bash %}
$ pdfinfo -l -1 demo.pdf
...
Page    1 size: 592.56 x 792 pts
Page    1 rot:  0
Page    2 size: 592.56 x 792 pts
Page    2 rot:  270
Page    3 size: 592.56 x 792 pts
Page    3 rot:  0
Page    4 size: 592.56 x 792 pts
Page    4 rot:  270
Page    5 size: 592.56 x 792 pts
Page    5 rot:  0
...
{% endhighlight %}

I didn't found any official documentation specifying that just discovered
it by trial and error.
