---
layout: post
tags: [ruby, rspec]
---
RSpec has a tiny little matcher to test arrays which is not so easy to be found
in documentation. The matcher is: `=~` (same as regex match operator). Example:

{% highlight ruby %}
it 'should pass' do
  %w(a b c).should =~ %w(b a c)
end
{% endhighlight %}

The documentation for this matcher says that this matcher checks whether actual
array contains all elements of the expected array regardless the order. Well this
isn't fortunate description because if actual array will include expected array
together with some additional elements the test will fail:

{% highlight ruby %}
it 'will fail' do
  %w(a b c d).should =~ %w(a b c)
end
{% endhighlight %}

The result is:

{% highlight bash %}
Failure/Error: %w(a b c d).should =~ %w(a b c)
       expected collection contained:  ["a", "b", "c"]
       actual collection contained:    ["a", "b", "c", "d"]
       the extra elements were:        ["d"]
{% endhighlight %}

So the matcher in fact tests if both actual and expected arrays contain same
elements regardless the order.

This matcher doesn't support `should_not`. More information can be found [here](https://github.com/dchelimsky/rspec/blob/master/lib/spec/matchers/match_array.rb).
