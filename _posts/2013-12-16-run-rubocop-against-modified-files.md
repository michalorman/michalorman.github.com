---
layout: post
tags: [ruby, rubocop]
---
If you are using [RuboCop][1] and like me you are working with some
legacy codebase you may be interested in running this tool only against
the files you've modified. Following snippet will do exactly that:

{% highlight bash %}
git status --porcelain | cut -c4- | grep '.rb' | xargs rubocop
{% endhighlight %}

More convenient script may be found [here][2].

[1]: https://github.com/bbatsov/rubocop
[2]: https://raw.github.com/michalorman/dotfiles/master/bin/rb
