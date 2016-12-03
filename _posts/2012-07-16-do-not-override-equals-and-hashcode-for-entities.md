---
layout: post
tags: [java, jpa, hibernate]
---
If you're tempted to override `equals()` and `hashCode()` methods for
your entity classes **don't do it!**. Simply do not override those
methods at all. Ever. It is extremely hard task to override those methods
correctly for entities, and in 99% cases default implementation -
basing on Java object's identity - will be fine for your application. In fact I never
saw a single correct implementation of `equals()` and `hashCode()`. If
you have one please share it, so I can prove it is wrong
implementation.

Lately on one of my projects I've encountered following implementation
of `hashCode()`:

{% highlight java %}
@Override                       
public int hashCode() {         
	if (id == null)                
		return super.hashCode();      
	return id.hashCode();          
}                               
{% endhighlight %}

God, please. Read the `hashCode()` contract before you start
overriding it:

> Whenever it is invoked on the same object more than once during an
> execution of a Java application, the hashCode method must
> consistently return the same integer 

In given implementation entity will return different hash code before
and after it has been persisted.

I won't show `equals()` method implementation as it was so absurd that
it is even not worth mentioning it.

So as a summary. Rule of thumb is **never override `equals()` or
`hashCode()` methods for entity classes**. If you feel that you must
do it rethink if your design is correct (you're not dealing with
separate JPA/Hibernate sessions?) or cannot the same be achieved using
`Comparator` or `Comparable` interfaces. It is better to find
workaround for those 1% cases whereas in 99% default implementation
will work just fine.
