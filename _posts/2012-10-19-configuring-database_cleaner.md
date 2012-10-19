---
layout: post
tags: [database_cleaner, rspec, ruby]
---
If you're using [database_cleaner](https://github.com/bmabey/database_cleaner) for your
RSpec and Capybara tests configuration for RSpec from
database_cleaner's documentation might not work for tests flagged with ``js: true``
(tests using javascript driver like Selenium). Transaction strategy basically doesn't
work in this type of tests. However changing strategy to *truncation* makes all other
test run considerably slower. If you want to use *truncation* strategy for JS tests
and *transaction* in all the other use following configuration:

{% highlight ruby %}
config.before :suite do
  DatabaseCleaner.clean_with :truncation
end

config.before :each do
  DatabaseCleaner.strategy = :transaction
end

config.before :each, js: true do
  DatabaseCleaner.strategy = :truncation
end

config.before :each do
  DatabaseCleaner.start
end

config.after :each do
  DatabaseCleaner.clean
end
{% endhighlight %}

The `DatabaseCleaner.clean_with` executed before each suite will ensure the database
is clean even if some failed/bugged tests left database uncleaned.
