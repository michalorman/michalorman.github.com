---
layout: post
tags: [java, oop]
---
Continuing thoughts from my [last post](/2012/04/stop-writing-static-methods)
I follow with another overused bad practice. It is
[Singleton Pattern](http://en.wikipedia.org/wiki/Singleton_pattern),
more precisely how singletons are created and instantiated.

Firstly notice that I'm saying stop *writing singletons* not *stop
using* it. What does it mean? It is nothing bad to have class which only
one instance can exist. However this behavior shouldn't be achieved
programmatically, it should be managed either by the JVM or by the
container. You should tell the container to create just one instance
of a given class and share it across all objects within the
container. What you shouldn't do is to implement singleton like this:

{% highlight java %}
public class Singleton {
        private static final Singleton instance = new Singleton();
 
        private Singleton() { }
 
        public static Singleton getInstance() {
                return instance;
        }
}
{% endhighlight %}

It is wrong because you retrieve instance via a static method, and if
you read my last post you know why you shouldn't write static
methods. Retrieving singleton instance using static method creates
tight coupling while we should design loose coupling. Also class using
the singleton cannot be tested in isolation. We cannot provide mock
implementation of a singleton and verify if it is correctly
used. Lastly singleton is a form of global state which in general
should be avoided unless you have very good reason to have it.

Singletons should be instantiated and managed by the containers. Use
[Spring](http://www.springsource.org/) or
[Guice](http://code.google.com/p/google-guice/) to create singletons
for you and inject them to your classes. This way you will have code
with loose coupling, open for modifications and most important classes
will be testable.
