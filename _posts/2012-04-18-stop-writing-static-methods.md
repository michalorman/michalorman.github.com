---
layout: post
tags: [java, oop]
---
**Object Oriented Programming** is very popular for quite a time, however
still lot of developers have problems with understanding it. One of
the most common problems is overuse of static methods. While it is a
quick and easy way to implement some functionality, it also the
quickest way to create untestable and unmaintainable code. So next
time you want to create static method - don't do it! Try to apply some basic
OOP rules, and if those fails you can implement method as static.

So why static methods are so dreadful? As I said it is a quickest way
to create untestable code. Static method itself is testable, however
code using static methods is not. Try to write test to method which
relies on current time, and retrieves current time like this:

{% highlight java %}
long now = System.currentTimeMillis();
{% endhighlight %}

You cannot mock the result of calling static method therefore you
cannot predict the result of such method so you cannot write a
test. Ok there is a [PowerMock](http://code.google.com/p/powermock/)
that can stub static method, but this is a rather hack than a
solution.

So how we can avoid writing static methods? Let's assume that we want
to create method that draws some shape, say a rectangle, on a
bitmap, but we do not want to create an rectangle object when we want to draw
it. What we can do? First write a signature of a static method, that you want to create:

{% highlight java %}
public static void drawRect(Bitmap b, int x, int y, int w, int h) {
    // drawing a rectangle on a bitmap
}
{% endhighlight %}

In order to make a non-static method from a static method you need to
find an object on which you will invoke the method. This object you will
find in a parameter list of a static method (most certainly it will
be the first parameter). So to make this method non-static you can
write this:

{% highlight java %}
public class Bitmap {
    private int[] pixels;

    public void drawRect(int x, int y, int w, int h) {
        // drawing a rectangle on a bitmap
    }

}
{% endhighlight %} 

But then you realize that drawing a rectangle is not really a
responsibility of a bitmap. You want the bitmap object to be a wrapper
for pixels. How to solve this? Think again about what you want to do. You
want to draw a rectangle on a bitmap which is in fact your drawing
surface. So you can create an abstraction `Surface` (sometimes it is
called `Canvas`) like this:

{% highlight java %}
public class Surface extends Bitmap {
    public void drawRect(int x, int y, int w, int h) {
        // drawing a rectangle on a bitmap
    }
}
{% endhighlight %}

This design works, but it is still not a perfect solution. It is bad
because inheritance shouldn't be used in this situation. Why? Because
code is still untestable! How you will write a test for `drawRect()`
method? You will need to add `int[] getPixels()` method, to check if
rectangle was correctly drawn, but in cost of breaking encapsulation and
exposing `Surface` internal implementation. Remember:

> Whenever you need to add a method to a class to make it testable you're
> doing it wrong. Think again about your design.

And another thing to remember:

> Favor aggregation over inheritance.

So applying this rule we have:

{% highlight java %}
public class Surface {
    private Bitmap bitmap;

    public Surface(Bitmap bitmap) {
        this.bitmap = bitmap;
    }

    public void drawRect(int x, int y, int w, int h) {
        // drawing a rectangle on a bitmap
    }
}
{% endhighlight %}

This class is perfectly testable because you can inject some mock
implementation of a `Bitmap` class and verify that it is correctly
used when invoking `drawRect()`.

But what if we cannot rewrite static method to a non-static version?
Eg. we want to get current time using `System.currentTimeMillis()`?
We can wrap static call with an object providing non-static implementation
like this:

{% highlight java %}
public class SystemTime {
    public long getCurrentTime() {
        return System.currentTimeMillis();
    }
}
{% endhighlight %}

You can inject this object to your classes and for tests you can use
implementation that will return fixed time, therefore you can predict
the result of a time-dependent method. Note that this also applies
whenever you retrieving current date like this:

{% highlight java %}
Date date = new Date();
// operations on date
{% endhighlight %}

Doing above you're creating untestable code! Add `getCurrentDate()`
method to `SystemTime` and inject this object wherever you need to
retrieve current date. For tests you can return fixed date and results
of your methods may be predicted and tested.

You may ask if there is any valid case to implement static method? The answer
is yes for Java language, because in Java you cannot extend core
classes like `String` (what can be done eg. in Ruby). Following is a
valid static method:

{% highlight java %}
public class StringUtils {
    public static boolean hasText(String s) {
        return s != null && !s.trim().isEmpty();
    }
}
{% endhighlight %}

This method should exist in `String` class (as this is a first
parameter in static method signature), however you cannot extend
it in Java so static method is your only option in this case.

If we are in this point. Please, for heaven's sake, do not mark
classes with `final` keyword. Really, there is no valid excuse to do
so, and it cause more problems than it solves, especially if you're
creating a library. And follow OOP rules. They were created not
because OO is cool, but to solve problems that developers had.
