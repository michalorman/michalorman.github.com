---
layout: post
title: There's a gem for that
---
If you're Ruby on Rails developer, especially the fresh one,
whenever you start working on a new task first thing you're doing
is navigating to sites like [The Ruby Toolbox][1] and search for a gem
which is already solving your issue. While this seems to be a
reasonable idea it boils down it is a double-edged sword.

Gem is nothing else than a library that someone wrote and shared.
You can find a gem for pretty much everything. If the solution is there
why should I use it you ask? Why to reinvent the wheel?

## The cost of a dependency

Gems are dependencies and those aren't coming without the cost.
You need to learn how to use it and accept all design decisions gem
author made. You need to follow gem updates or whether gem is still
actively maintained or maybe it was abandoned by its author and some
alternative should be used. Whenever you'd like to upgrade your platform you'd need
to verify if your dependencies are working with the recent version
of Rails. Sometimes they'll produce ton of annoying deprecation warnings
sometimes will stop working at all (it can even happen silently).

As in your code you'd like to have loose coupling and as few
dependencies as possible same concept applies to external libraries.
Each dependency is a burden. At some point it can simply overwhelm project.

Another problem is that not always will be easy to tailor the dependency
to the specific project requirements. On my project we were using jQuery
plugins to implement certain features but at the end tweaking those to
support our specific requirements was such a pain that I've end up
removing all of them and re-writing from scratch.

## ...

I'm not trying to say not to use dependencies at all but rather
to do a good judgement about whether external library is really the best
option.

Once on one of my projects we were integrating with Zendesk to submit
user support tickets. The developer decided to go with one of the available
gems. It has some weird design and was implementing full Zendesk API
whereas the only thing we've needed was to submit a ticket which could
be done with one simple REST call via any HTTP client (including `curl`).
At some point we weren't even able to do some basic change due to the
gem's design and at the end developer decided to ditch it and wrote
basic HTTP call with all we needed.

Similar thing I see frequently for any OAuth service. The OAuth flow is
very simple and it's just plain HTTP. But for some reason developers
needs to implement it using some gem. And the designs and API's of those
gems are so bizarre in most cases or questionable in the best case. I guess
when developers see how much boilerplate they need to do in order to
initiate simple OAuth flow they think it must be so complicated thus there's
no other way than use help of some gem.

Other times we were developing simple Chrome extension. The whole extension
was around 100 lines of JavaScript. Problem is that the developer wanted
to use a stack he liked (ES6, Babel). So we end up with 719 dependencies total
(including dependencies of a dependencies) and it was the only extension
out of few we had which had its dedicated build system to get the CRX file.

So the problem is that developers seems to overuse libraries often for very
simple things which can be easily written in few lines of codes (I saw
people using gems for things like email validation). Developers should think
about future maintainability not only about current problem they're solving.
Gems may get outdated, abandoned, deprecated. At some point you're going
to do some major upgrade and you're dependencies will stay on the way.

[1]: https://www.ruby-toolbox.com/
