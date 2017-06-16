---
layout: post
title: Don't use default_scope
---
There are many opportunities you may be tempted to use `default_scope`.
I did it many times. Want to not return models marked as removed? It's
easy as writing:

{% highlight ruby %}
default_scope where(removed: true)
{% endhighlight %}

You want to fetch models always ordered? It's simple just write:

{% highlight ruby %}
default_scope order('created_at desc')
{% endhighlight %}

It boils down that in both cases it is a bad idea to use
a `default_scope`. There are lot of consequences that everybody
would need to live with when applying a `default_scope`.

Let start with adding `order` in a `default_scope`. Suddenly
calls like `User.first` or `User.last` can return opposite values.
A `first` would return last record and vice versa. You'd need to
remember to unscope the model before calling any of it.

As for the first example there could be some scenarios
in which you would be interested in removed records: admin management,
reporting, testing, etc. In all those contexts you'd need to
always make sure to unscope the models.

Another problem is that default scope will be applied to relations
and it's not easy to unscope those. Rather you'd need to rewrite
queries. For example:

TODO: example with sql log
{% highlight ruby %}
User.posts
{% endhighlight %}

Above returns posts which aren't removed. But if you're interested
also in removed posts (eg. for analytics) you'd need to rewrite
it like this:

{% highlight ruby %}
Post.unscoped.where(user_id: user)
{% endhighlight %}
