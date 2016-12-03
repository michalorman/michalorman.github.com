---
layout: post
tags: [oop, architecture, ruby]
---
After a few [lost years in software architecture][1], during which developers were rushing
towards so called "productivity" using word "pragmatic" as a justification for their poor design,
finally we are experiencing conversion towards the good old OOP practices (or abandoning OO programming at all). As hacked out codebases growth
developers realized that maintainability, testability and extendability is an important factor. It's a perfect
opportunity to remind some basics.

One of less known principles is [command-query separation (CQS)][2]. As introduced
CQS applied to methods, but over time it was also applied for application architecture where query and command interfaces were
clearly separated. In this post I'd cover the former case.

The idea behind the CQS is to divide methods into following categories:

- **Queries**, which examine system's state, returns value and do not cause side effects.
- **Commands**, which change the state of a system (world) but do not return a value.

We use queries to test object's or system's state while commands are used to
mutate that state. Personally I like to extend this list with **Factory** methods, which
are somewhat a combination of command and query. The purpose of a factory method is to
create and return an object. It is an abstraction over object creation process.

## Queries

Query method examines the state of a system. I'm using a word system instead of object by
purpose, as tests are not limited to a single object. For example testing file existence
is communicating via file system not just checking whether object's file attribute is set.

Query methods are those which look like this:

{% highlight ruby %}
process.pending?
File.exists?(path)
transaction.state
{% endhighlight %}

Executing above methods should never change the state of any part of a system. However it is allowed
that the result of a query method is evaluated lazily, eg.:

{% highlight ruby %}
s3object.exists?('/some/s3/key')
{% endhighlight %}

The S3 connection can be established whenever it is needed (`exists?` method called).

This type of methods should rather return primitive values which are used for control
execution flow (it means that values returned by query methods are used in condition
statements like `if`). Why you should prefer returning primitive values instead of
regular object? To **avoid train wrecks** (and do not violate the [Law of Demeter][4]).

Train wreck is something like this:

{% highlight ruby %}
user.profile.address.street
entry.where(type: :draft).joins(:attachmenets).all
{% endhighlight %}

Train wrecks are considered as a code smell. You might be asking why you should avoid
train wrecks? They're so convenient! Well if convenience is everything you need from
the code then go ahead and write them, but if you are serious about testability
and maintainability then embrace delegation! Delegation encapsulates implementation
details, as the caller shouldn't care how to get a `street` out of a user `object`. Train
wrecks are fine for simple and small apps. But if you expect that application will grow
(and which nowadays isn't?) it's better to avoid them earlier than later.

Train wrecks are why many developers find so difficult writing tests. The amount of stubbing they
need to do in order to test simple things is overwhelming. We're calling that setup hell or pain.
Delegation basically boils down mocking to just one method call drastically reducing the
code required to setup a test.

We could argue the `ActiveRecord` example as by some those kind of implementation is called
[Fluent Interface][5]. However it is very hard to unit test it as tests requires bazillion of
stubs and mocks of objects returned along to the `all` method invocation. That chain exposes
lot of implementation details like used interface - ActiveRecord, database type - Relational,
supporting join statements, column name - `type` together with its allowed value - `draft`
relation - `attachments`. Lot of [reasons to change][6].

## Commands

As said, commands are used to mutate the state of a system. They instruct object to
perform some action. Typically they shouldn't return value as commands are not used to
flow control, however often we see violation of that rule, one of which is in my opinion
acceptable and is called a factory method.

Commands are methods which looks like this:

{% highlight ruby %}
Resque.enqueue(SendNotificationJob, user_id)
user.save
document.ready!
service.call(transaction_id)
{% endhighlight %}

For some reason developers often violate rule of not returning a value by commands. Most
often they return `true` or `false` to indicate whether command performed successfully or
not (or to be more precise they are returning values which evaluates to `true` or `false`).
Well this is the fastest way to get spaghetti code with a lot of `if`-`else` statements.
Commands and their return values shouldn't be used for flow control. Commands should follow
invoke and forgot approach. If anything goes wrong exception should be raised.

### Factories

Factories weren't originally specified when CQS term was crafted. However I'm defining them
as a special type of commands. The purpose of a factory method is to encapsulate object
creation. It creates and returns new object.

Example of factories are:

{% highlight ruby %}
@post = Post.create(post_params)
@user = CreateUser.call(user_params)
{% endhighlight %}

Except the returned value factories there are no other differences between factories and commands.

## Why should I care?

Knowing the method type is very useful as it indicates how to write tests. Queries are
mostly stubbed whereas for commands we need to setup a mock expectation ensuring command
execution with correct parameters. To learn more about stubs and mocks I suggest reading
Uncle Bob's [The Little Mocker][3] post.

Knowledge about method type makes much easier to avoid typical code smells and allows making
code more maintainable and easier to test. Personally I like to identify the piece of code
which can be wrapped into a command method with single responsibility. That allows me
making methods which are much shorter and easier to read as well designed code [passes the tests
and reveals intention][7].

[1]: https://www.youtube.com/watch?v=HhNIttd87xshttps://www.youtube.com/watch?v=HhNIttd87xs
[2]: http://en.wikipedia.org/wiki/Command%E2%80%93query_separation
[3]: http://blog.8thlight.com/uncle-bob/2014/05/14/TheLittleMocker.html
[4]: http://en.wikipedia.org/wiki/Law_of_Demeter
[5]: {% post_url 2014-06-04-testing-inside-and-outside-boundaries %}
[6]: http://blog.8thlight.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html
[7]: http://martinfowler.com/bliki/BeckDesignRules.html
