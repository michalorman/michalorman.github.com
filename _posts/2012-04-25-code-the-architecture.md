---
layout: post
tags: [architecture, oop]
---
Simon Brown did a great talk about the
[role of a software architect](http://www.infoq.com/presentations/The-Frustrated-Architect). Having
a bunch of architects that do the design which is further implemented
by team of developers is really not the way software should be
developed. Simon says:

> Architecture should be coded, not managed.

If architect isn't at
least interested how his architecture is being implemented, how he can
prove that his architecture is implementable at all? If at the end software
do not meet requirements, do not scale enough is it because of the bad design, or developers
improperly implemented it?

Unfortunately it is very common that developers are treated as
brainless machines that just type code. Those who gains certain level of
experience became software architects, and since then create diagrams
and designs which is implemented by less experienced
(and less paid) developers. The problem with this model is that such
architects do not evaluate if their design actually works. If it doesn't work
they blame developers (those idiots cannot implemented thing that was
given and fully documented in the design). They also miss the feedback
from the developers.

**Software architect should be a role** in a project rather just a
position in the company. Architect should be a part of a team and
shouldn't be responsible only for design. He should be
responsible for proper implementation of a design together with other
team members which plays other roles in a project. It doesn't mean
that architects must code though they should be able and at least
should be interested how their architecture is being implemented. Close
collaboration with team members that play architect and other roles
is a must in order to guarantee the implementability of an architecture. It
also supports principle of [ubiquitous language](http://domaindrivendesign.org/node/132).
Collaboration also guarantees quick feedback about the
correctness of an architecture and sharing knowledge and experience
across all team members (so after a while we have a whole team of architects).
