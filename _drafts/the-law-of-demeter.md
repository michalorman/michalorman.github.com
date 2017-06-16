---
layout: post
title: The Law of Demeter
---
Quite often I come across a code which looks similarly to the
following snippet:

{% highlight ruby %}
def charge(user)
  ProcessBilling.call(user.credit_card)
end
{% endhighlight %}

Above code doesn't seem to be harmful at all. We want to charge
a user so we take his credit card information and pass it to some
`ProcessBilling` service.

Yet what would happen if we'd introduce anonymous pay as you go model
where we don't have a user at all? We'd need to refactor this method
and each place which is using it (and all corresponding tests). We know
that under the name of the [Shotgun Surgery][1].

So what's wrong? Apparently a `user` isn't a parameter for this method.
Real parameter is credit card. We pass `user` to get `credit_card` out
of it.

Let's take a look on how the test of such method may look like:

{% highlight ruby %}
let(:credit_card) { double 'credit_card' }
let(:user) { double 'user', credit_card: credit_card }

it 'process the credit card through billing' do
  expect(Billing).to receive(:process).with(:credit_card)
end
{% endhighlight %}

Recently I've heard this brilliant quote:

> Tests are the first consumer of your API. If the first consumer
> has to do questionable things to work with the API,
> chances are your production code will too.

We need to setup 2 test doubles in order to test simple method call
with a single parameter? Isn't that questionable?

What we'll had to do in production code in order to use a `charge` method
and not modify it? Probably something like this:

{% highlight ruby %}
charge(
  OpenStruct.new.tap do |s|
    s.credit_card = credit_card
  end
)
{% endhighlight %}

We'd just wrap the credit card info into some object which quacks like
a user. Ugh!

[1]: https://sourcemaking.com/refactoring/smells/shotgun-surgery
