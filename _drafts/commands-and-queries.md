---
layout: post
tags: [oop, architecture, ruby]
---
After a few [lost years in software architecture][1], during which developers were rushing
towards so called "productivity" using word "pragmatic" as a justification for their poor design,
finally we are experiencing conversion towards the good old OOP practices (or abandoning OO programming at all). As hacked out codebases growth
developers realized that maintainability, testability and extendability is an important factor. It's a perfect
opportunity to remind some basics.

One of the less known principles is [command-query separation (CQS)][2]. As introduced
CQS applied to methods, but over time it was also applied for application architecture. In
this post I'd cover the former case.

The idea behind the CQS is to divide methods into following categories:

- **Queries**, which examines systen's state, returns value and do not cause side effects.
- **Commands**, which changes the state of a system (world) but do not return a value.

The idea is that we use queries to test object or system state while commands are used to
mutate that state. Personally I'd like to extend this list with **Factory** methods, which
are somewhat a combination of command and query. The purpose of a factory method is to
create and return an object. It is an abstraction over object creation process.

Let see what is characteristic about each of a method type.

## Queries

Query method examines the state of a system. I'm using word system instead of object by
purpose, as tests are not limited to a single object. For example testing file existence
is communicating via file system not just checking whether object's file attribute is set.

Query methods are those which looks like this:

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

The S3 connection can be established whenever it is needed (`exists?` method called) and
not on S3 object creation.

This type of methods should rather return primitive values which are used to control
execution flow (it means that values returned by query methods are used in condition
statements like `if`). Why you should prefer returning primitive values instead of
regular object? To **avoid train wrecks** (and do not violate the [Law of Demeter][4]).

Train wreck is something like this:

{% highlight ruby %}
user.profile.address.street
entry.where(type: :draft).joins(:attachmenets).all
{% endhighlight %}

Tran wrecks are considered as a code smell. You might be asking why you should avoid
train wrecks? They're so convenient! Well if convenience is everything you need from
the code then go ahead and write train wrecks, but if you are serious about testability
and maintainability than embrace delegation! Delegation encapsulates implementation
details, as the caller shouldn't care how to get a `street` out of a user `object`.

Train wrecks are why people find so difficult writing tests. The amount of stubbing they
need to do in order to test simple things is overwhelming. Delegation basically boils down
mocking to just one method call.

We could argue the `ActiveRecord` example as by some those kind of implementation is called
[Fluent Interface][5]. And yes, in this example we are not exposing implementation details,
however it is very hard to unit test that as it requires bazillion of stubs and mocks of
objects returned along to the `all`.

### Testing queries

Well, the thing about query methods is that they do not need to be tested at all. While the
value of a query method is used to control the flow you should focus on testing the flow. To
do that you only need to stub the result of a query method and check whether the control flow
behaves as expected. In Rspec you can do it in two ways.  Using `allow`:

{% highlight ruby %}
context "when user is valid" do
  before do
    # stub the valid? method
    allow(user).to receive(:valid?).and_return(true)
  end

  it "schedules email notification" do
    # test execution flow
    expect(Resque).to receive(:enqueue).with(DeliverWelcomeEmailJob, user.id)

    subject.call(params)
  end
end

context "when user is not valid" do
  before do
    # stub the valid? method
    allow(user).to receive(:valid?).and_return(false)
  end

  it "doesn't schedule email notification" do
    # test execution flow
    expect(Resque).to_not receive(:enqueue)

    subject.call(params)
  end
end
{% endhighlight %}

Alternatively you can stub query method while creating a double:

{% highlight ruby %}
context "when user user is valid" do
  # stub the valid? method
  let(:user) { double valid?: true }

  it "schedules email notification" # same as above...
end

context "when user is not valid" do
  # stub the valid? method
  let(:user) { double valid?: false }

  it "doesn't schedule email notification" # same as above...
end
{% endhighlight %}

Those tests will cover execution of query method (`valid?` in this case) and whether the
execution flow is correct depending on the value returned by that method. There is no need
to setup a mock expectation for calling a query method.

If you are not familiar with a difference between stub and mock expectation I strongly
encourage you to read Uncle Bob's [The Little Mocker][3] post.

## Commands

As said, commands are used to mutate the state of a system. They instruct object to
perform some action. Typically they shouldn't return value as commands are not used to
flow control. However often we see violation of that rule, one of which is in my opinion
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
Well this is the fastest way to get spaghetti code with lot of `if`-`else` statements.
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

### Testing commands

As queries don't need to be tested commands do. You need to ensure that your code
is executing commands properly, and by properly I mean commands are executed at all and
with proper parameters.

The way commands are tested depends on a type of a test. In unit testing you need to
write mock expectation that verifies if and how the command was executed. Such mock expectation
will look like this:

{% highlight ruby %}
it "enqueues email delivery" do
  expect(Resque).to receive(:enqueue).with(DeliverRegistrationEmailJob, user.id)
  subject.call(user_params)
end
{% endhighlight %}

You should check whether the command was executed and if the parameters were correct.

Above example is a test for some user registration service. I like to test my services
in isolation for reasons I've described in one of my [previous posts][5].

In integration/acceptance test you won't write mock expectations. Rather you will examine
the expected outcome (like there should be new job enqueued, some file created, etc.).

[1]: https://www.youtube.com/watch?v=HhNIttd87xshttps://www.youtube.com/watch?v=HhNIttd87xs
[2]: http://en.wikipedia.org/wiki/Command%E2%80%93query_separation
[3]: http://blog.8thlight.com/uncle-bob/2014/05/14/TheLittleMocker.html
[4]: http://en.wikipedia.org/wiki/Law_of_Demeter
[5]: {% post_url 2014-06-04-testing-inside-and-outside-boundaries %}
[6]: http://
