---
layout: post
tags: [ubuntu, bundler, rails]
---
Lately I've experienced following problem while creating new rails
application:

{% highlight bash %}
Fetching gem metadata from https://rubygems.org/.........

Gem::RemoteFetcher::FetchError: SSL_connect returned=1 errno=0 state=unknown state: sslv3 alert handshake failure (https://d2chzxaqi4y7f8.cloudfront.net/gems/rake-0.9.2.2.gem)
An error occured while installing rake (0.9.2.2), and Bundler cannot continue.
Make sure that `gem install rake -v '0.9.2.2'` succeeds before bundling.
{% endhighlight %}

The problem seems to be caused by some bug in OpenSSL while it happens
on Ubuntu 12.04 and not on OSX (don't know how about windows). If the same
happens to you change `source 'https://rubygems.org'` to `source
'http://rubygems.org'` in your `Gemfile`.
