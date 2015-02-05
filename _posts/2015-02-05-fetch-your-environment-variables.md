---
layout: post
tags: [ruby, rails, architecture]
---
So you've just read [The Twelve-Factor App][1] and decided that you're going to
[store your configuration in the environment][2]. Armed with [dotenv][3] you've changed
configuration of AWS SDK to this:

{% highlight ruby %}
AWS.config(
  access_key_id:      ENV['S3_ACCESS_KEY'],
  secret_access_key:  ENV['S3_SECRET_KEY'],
  region:             ENV['S3_REGION']
)
{% endhighlight %}

Everything is working fine on your local machine, so you are making commit and pushing
changes to the origin. Now you need to update server configuration so you're adding following to
`.bashrc`:

{% highlight bash %}
export S3_REGION=us-west-2
export S3_ACCESS_KEY=CE358D4DB14B5BDAF5DCDD30E2C8BD7E
export S3_SECRET_KEY=55837e48dbcdf98d8277033086d5502b
{% endhighlight %}

Deploy, and... not working. Environment variables are not available. If you, like me,
always have problems figuring out whether you are in login/interactive shell or not, and
juggling configuration between `.bashrc` and `.bash_profile` perhaps [this][4] figure
will help you to understand where settings should go. But you must be aware, that if
you are using solutions like Upstart/Monit to start/stop your application, you can be
confused about which variables and what PATH is available for the application. From the other
hand you still want same variables to be available when you log in via SSH.

But this post is not about how to properly setup environment. It is about fetching
environment variables.

The problem I'd like to point out is related to the way
we are reading environment variables from `ENV`. In fact you can find that way of
obtaining env variables in Rails 4:

{% highlight ruby %}
# test/test_helper.rb
ENV['RAILS_ENV'] ||= 'test'

# config/secrets.yml
secret_key_base: <%= ENV['SECRET_KEY_BASE'] %>

# config/environments/production.rb
config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
{% endhighlight %}

The problem is that if we call `[]` on `ENV` with key that is missing `nil` will
be returned. That will probably cause weird errors which are far away from the real reason.
It might take some time figuring out that error is caused by misspelled or not configured
environment variable. Reading environment variables via `[]` does not allow gracefully
handle case when key is missing or set defaults (most probably we'd use `||=` to solve that).
There is a better way though.

## Use the `fetch` Luke

`ENV` is respoding to [`fetch`][5] similiary as `Hash` and `Array` are doing. That way
we can set default values or handle - providing a block - gracefully missing
keys. Also using `fetch` with unknown key will raise `KeyError` that will tell
us which exactly key is missing. That is in fact the behavior we are expecting from the app.
Without required settings is just not working and complaining about missing
setting and not about some random `nil` references.

So refining our previous example, the AWS configuration should look as follows:

{% highlight ruby %}
AWS.config(
  access_key_id:      ENV.fetch('S3_ACCESS_KEY'),
  secret_access_key:  ENV.fetch('S3_SECRET_KEY'),
  region:             ENV.fetch('S3_REGION')
)
{% endhighlight %}

The application will tell us which exactly key is missing in case we forgot to set it. Now
we can go back figuring out to which file environment variables should go to be available for
our application.

[1]: http://12factor.net/
[2]: http://12factor.net/config
[3]: https://github.com/bkeepers/dotenv
[4]: http://s0.cyberciti.org/uploads/cms/2015/01/BashStartupfiles.jpg
[5]: http://www.ruby-doc.org/core-2.2.0/ENV.html#method-c-fetch
