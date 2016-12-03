---
layout: post
tags: [rails, ruby]
---
Suppose you need to write a system daemon running in the context of Rails application,
so that you have access to your models or services. You might be tempted to use gems
like [daemons][1] but using such gems you'd need to load Rails environment manually as those are
not aware of Rails application context.
While such gems provides advanced functionality - like monitoring - they are additional
dependency that must be maintained. There is a simpler approach though that will work fine in
most cases.

The easiest way to load Rails environment is to execute `rake environment` task.
Combining it with any other rake task we can easily implement a daemon running in the context
of Rails application. In fact [Resque][2] (in version 1.x) embraces this approach. By reading
its code you can came up with the following template for simple daemons running in
the context of Rails:

{% highlight ruby %}
task start: :environment do
  Rails.logger       = Logger.new(Rails.root.join('log', 'daemon.log'))
  Rails.logger.level = Logger.const_get((ENV['LOG_LEVEL'] || 'info').upcase)

  if ENV['BACKGROUND']
    Process.daemon(true, true)
  end

  if ENV['PIDFILE']
    File.open(ENV['PIDFILE'], 'w') { |f| f << Process.pid }
  end

  Signal.trap('TERM') { abort }

  Rails.logger.info "Start daemon..."

  loop do
    # Daemon code goes here...

    sleep ENV['INTERVAL'] || 1
  end
end
{% endhighlight %}

Above daemon may work in background as well as in foreground. We can specify the
pid file, interval and log level. It can be started with following command:

{% highlight bash %}
BACKGROUND=y PIDFILE=daemon.pid LOG_LEVEL=info bundle exec rake start
{% endhighlight %}

To kill daemon:

{% highlight bash %}
kill `cat deamon.pid`
{% endhighlight %}

Monitoring should be delegated to tools like [Monit][3] which are far more powerful
than any gem providing daemon functionality. Finally we are't introducing any additional dependencies
which is always a good thing.

[1]: https://github.com/thuehlinger/daemons
[2]: https://github.com/resque/resque
[3]: http://mmonit.com/monit/
