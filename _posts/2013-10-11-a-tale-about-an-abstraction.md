---
layout: post
tags: [oop, patterns]
---
In most cases when I see `if`..`else` statement somewhere in the wild
it is an incorrectly, or not fully applied one of the *OOP* paradigms.
From my observations developers finds difficult to identify proper
abstractions. Of course its not wise to blindly abstract everything
just because it can be abstracted, but it is good to know when and
how we can introduce an abstraction if problem is (or will get) more complex.

Following is a snippet of a code that I've encountered lately.
The purpose of this class was to parse CSV file and return user
records. Sometimes users were
provided via email (in this case user should be created if doesn't
exist) or via an id (in this case it must exist). The class
should return all users that were found or created.

{% highlight ruby %}
class ParsesUsers
  def parse(csv)
    [].tap do |users|
      CSV.foreach(csv) do |row|
        users << user_from_email_or_id row[0]
      end
    end
  end

  private

  def user_from_email_or_id(cell)
    if is_number?(cell)
      # find user by id
    else
      # find or create by email
    end
  end
end
{% endhighlight %}

Obviously we we are violating [Tell Don't Ask Principle](http://martinfowler.com/bliki/TellDontAsk.html)
in `user_from_email_or_id` method. Also it looks that class has more than
[single responsibility](http://en.wikipedia.org/wiki/Single_responsibility_principle) even though it has just few lines of
code. How we can refactor? The simplest solution would be to delegate
logic from the `user_from_email_or_id` method to a `User` class:

{% highlight ruby %}
def user_from_email_or_id(cell)
  User.find_or_create(cell)
end
{% endhighlight %}

But I'm not a big fan of this approach. The problem is that this logic
**is not really logic that is core to `User` model**. It is a logic that
is required by the process of parsing the CSV file or other source.
We can say it is more related to importing process rather than to a
`User` model.

`User` model should take care of persisting users, validation and stuff
related to `ActiveRecord`. If we start putting all random business logic
into a `User` class it will quickly growth out of control and became
dreadful [God Class](http://sourcemaking.com/antipatterns/the-blob). And
this is a case that I most often encounter in Rails apps. Developers
blindly follow [fat model, skinny controller](http://joncairns.com/2013/04/fat-model-skinny-controller-is-a-load-of-rubbish/)
pattern putting all random unrelated business logic into model classes.
What we really need is some intermediate layer between controllers and models
as we have between models and views named presenters.

## Introducing an Abstraction

So what we can do rather than bloating `User` class with random business
logic? Well we have at least two options here. Either we build abstraction
over a `cell` which represents a single value of a CSV file (or basically
any input file). Or we build abstraction over a `User`.

#### Abstraction over a `Cell`

We can create a `Cell` class that will know how to create users from
its value:

{% highlight ruby %}
class Cell
  def initialize(value)
    @value  = value
    @number = is_number?(value)
  end

  def user
    if number?
      # find user by id
    else
      # find or create by email
    end
  end
end
{% endhighlight %}

{% highlight ruby %}
class ParsesUsers
  def parse(csv)
    [].tap do |users|
      CSV.foreach(csv) do |row|
        users << Cell.new(row[0]).user
      end
    end
  end
end
{% endhighlight %}

So what we really did with this refactoring is that we moved
the `if`..`else` statement to a `Cell` class. Thats true, but
instead of 1 class with several purposes (parsing and finding or
creating a user) we have 2 classes with single responsibilities.
We can easily test the `Cell` class and we can reuse it in other classes
that will parse other files.

#### Abstraction over a `User`

Alternative approach would be to build abstraction over a `User`
model. We could call it `IdentityUser`:

{% highlight ruby %}
class IdentityUser
  def initialize(identity)
    @user = load_by_identity(identity)
  end

  private

  def load_by_identity(identity)
    if is_number?(identity)
      # find user by id
    else
      # find or create user by email
    end
  end

  # delegations...
end
{% endhighlight %}

{% highlight ruby %}
class ParsesUsers
  def parse(csv)
    [].tap do |users|
      CSV.foreach(csv) do |row|
        users << IdentityUser.new(row[0])
      end
    end
  end
end
{% endhighlight %}

This approach is similar to [presenter pattern](http://blog.jayfields.com/2007/03/rails-presenter-pattern.html),
where instead of a `User` model we create some kind of intermediate object
and delegate calls to the real model.

Using this approach we have even more flexibility comparing to
previous one. We are not bound to the parsing input with cells, we
can reuse this class wherever we need. The trade-off is that we
need to implement methods delegating calls to a user model, but
we can implement them on demand as they are required (or using
some metaprogramming tricks via `method_missing`).

### Benefits of a proper abstraction

So what do we gain with proper abstraction? In either case we didin't removed
the `if`..`else` logic, and in most cases we are still violating
Tell Don't Ask Principle.

The main benefit is testability. In all cases we can very easy
test the logic that we are abstracting. In our case it is a very
simple logic, but usually things are more complicated. Often I see
developers that have problems testing controllers. Extracting logic
to a [service object](http://stevelorek.com/service-objects.html) easily
solves the problem.

Another benefit is that we have clean and reusable classes with single
responsibilities. Especially if we build abstraction over a
`User` model in our example. Also we can change the *business logic*
when a user is found or created, test-drive that change, and
have it working wherever we used our class without touching
consumers implementations.

#### When to know that abstraction may be introduced?

The easiest way to find out that you might be missing an abstraction
is when you scratch your head asking yourself: *How the hell I'm gonna to test
that?*. It is in generall very good practice, if for some reason you
are not doing **TDD**, asking yourself how are you gonna test the
solution that you are implementing at the moment.

So pay attention when you encounter following:

* Test requires huge setup of stubs/mocks and data.
* In order to test logic you are invoking a method that is invoking
a method you are testing.
* You are broading the visibility of a method in order to
test it (sic!).

Last 2 points in general means that logic that you want to test
is hidden somewhere deep in a tested class internals. And in fact you shouldn't
be testing internals at all. Extracting logic that you want to test
is an only solution you can do to solve this problem. You can extract
this logic as a Service, Policy or Strategy object.

## Disclaimer

To be honest in our case we left original implementation and skip the
refactorings. For us it was a temporal solution, that we wanted to replace
with better one. Each time you want to apply refactoring you
should consider if it is worth doing given the context. Sometimes
simple, procedural implementation is good enough and there is no point
to refactor it.

Also note that it is fine to violate some *OOP* principles. Given a
context of course. Principles are guidelines but you shoudn't apply them
blindly. Personally there is only one rule that I apply blindly. It
is [Single Responsibility Principle](http://en.wikipedia.org/wiki/Single_responsibility_principle).
This principle allows me to write small, simple classes that can be
easily tested which is a foundation to write better code.
