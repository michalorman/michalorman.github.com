---
layout: post
tags: [java]
---
After about 5 years of development in Java I've decided to take OCPJP
exam. I even attend to special training just to prepare myself for
exam gotchas and remind things that I normally do not use during
development. Here are some funny and mostly useless facts about Java
that most developers probably don't know.

## Enum package-private constructor

Ok, so everybody knows that enums can have private constructors. But
not everybody knows that we can define constructor of an enum without
modifiers:

{% highlight java %}
public enum Shape {
    TRIANGLE(3), RECTANGLE(4);
    Shape(int vertices) {
        // ...
    }
}
{% endhighlight %}

Don't be fooled however. It doesn't mean that enum's has
`package-private` constructor which can be invoked from other classes
within the same package. Java specification states clearly:

> If no access modifier is specified for the constructor of an enum
> type, the constructor is private.

So in enum case constructor is always private either it is declared
explicitly or implicitly.

## Array constructor

Array is an `Object` that's a fact. So if array is an object than it
must have a class while it must respond to object's `getClass()`
method (even though there is no `java.lang.Array` class defined in
Java library). Have you ever wondered if array's class has constructors, which
can be retrieved via reflection and used to instantiate new array?

So consider following code:

{% highlight java %}
public class ArrayTest {
    public static void main(String... args) {
        int[] arr = { 1, 2, 3 };

        System.out.println(arr.getClass().getSimpleName());
        System.out.println(arr.getClass().getDeclaredConstructors().length);
        System.out.println(ArrayTest.class.getSimpleName());
        System.out.println(ArrayTest.class.getDeclaredConstructors().length);
    }
}
{% endhighlight %}

This code produces following output:

{% highlight bash %}
$ java ArrayTest 
int[]
0
ArrayTest
1
{% endhighlight %}

So despite array has some class (`int[]`) this class doesn't have any
constructors. Haven't we been told that every class has a constructor
even if we do not declare any? Well not in case arrays, they are
special kind of classes.

If you want to create new instance of an array you should use
`java.lang.reflect.Array`.

## Useless arrays

There is another case where array's are treated specially, this time
by the compiler. Did you know that following expression doesn't
compile?

{% highlight java %}
new int[] { 1, 2, 3 };
{% endhighlight %}

Despite that following compiles fine:

{% highlight java %}
int[] arr = new int[] { 1, 2, 3 };
{% endhighlight %}

Similarly following expression doesn't compile:

{% highlight java %}
(new int[] { 1, 2, 3 }).length;
{% endhighlight %}

While this does:

{% highlight java %}
int size = (new int[] { 1, 2, 3 }).length;
{% endhighlight %}

In case of regular classes it is fine to create object and drop it in
the same expression. In case of arrays compiler check if we really do
something with this array. It even doesn't gets fooled with accessing
array's `length` field. Compiler checks if we at least assign it  to
some variable.
