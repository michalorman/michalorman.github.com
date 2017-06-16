---
layout: post
---
# TL;DR

Always explicitly set encoding for Base64 decoded input as it defaults
to ASCII.

{% highlight ruby %}
Base64.decode64(input).force_encoding('utf-8')
{% endhighlight %}

# Base64 encoding problem

Base64 comes handy when we need to represent binary data in ASCII.
For example when transferring a file or storing encryption key.

The other use case when Base64 is useful is when we can handle only
ASCII characters but user may provide non-ascii strings. In such case
we encode string on one end transfer encoded input and decode on the other
end. You may however be surprised that this may not work straight in
Ruby.

{% highlight ruby %}
encoded = Base64.encode64('Zażółć gęślą jaźń.')
=> "WmHFvMOzxYLEhyBnxJnFm2zEhSBqYcW6xYQu\n"
Base64.decode64(encoded)
=> "Za\xC5\xBC\xC3\xB3\xC5\x82\xC4\x87 g\xC4\x99\xC5\x9Bl\xC4\x85 ja\xC5\xBA\xC5\x84."
{% endhighlight %}

Decoding what was previously encoded with standard `Base64` class
doesn't return the same value which was encoded. It is because
`Base64` can't determine input's encoding and decodes in 8-bit ASCII:

{% highlight ruby %}
Base64.decode64(encoded).encoding
=> #<Encoding:ASCII-8BIT>
{% endhighlight %}

It is very difficult task to guess input's encoding but surprisingly
`decode64` doesn't accept any parameter allowing to set the desired encoding
and just defaults to ASCII.

To make above example work string encoding needs to be forced manually:

{% highlight ruby %}
Base64.decode64(encoded).force_encoding('utf-8')
=> "Zażółć gęślą jaźń."
{% endhighlight %}
