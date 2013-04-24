---
layout: post
tags: [ruby, rails, squeel]
---
Writing complex queries in plain ActiveRecord is sometimes cumbersome.
We need to fallback to write SQL-ish queries as plain strings which could
cause errors and is not a way we should query using ORM frameworks. However
there is very interesting solution for this problem called [Squeel](https://github.com/ernie/squeel).
As its GitHub page says Squeel improves ActiveRecord *by making the ARel
awesomeness that lies beneath Active Record more accessible.*

So according to its documentation we can rewrite this:

{% highlight ruby %}
Article.where ['created_at >= ?', 2.weeks.ago]
{% endhighlight %}

into this:

{% highlight ruby %}
Article.where{created_at >= 2.weeks.ago}
{% endhighlight %}

Pretty nice in my opinion.

Now lets look at some more complex example. We have presentations
that belongs to conference either via direct relation (`conference_id` in
`Presentation` model), or through some event (`event_id` in `Presentation`
and `conference_id` in `Event` model). Presentation could also
be not yet assigned to any conference. Now we have admin panel with
admin users dedicated to manage certain set of conferences and we
want to scope presentations on view to only those which belongs to
managed conferences, or which aren't yet assigned to any (BTW if you are using
[ActiveAdmin](http://activeadmin.info/) you can scope the queries
using [`scope_to`](http://activeadmin.info/docs/2-resource-customization.html)).
We need proper scope for this task, and one could be easily written
using Squeel:

{% highlight ruby %}
# models/presentation.rb
scope :unassigned_or_assigned_to, ->(conferences) do
  includes(:sessions).where{ (conference_id >> conferences) |
    (events.conference_id >> conferences) |
    ((conference_id == nil) & (events.conference_id == nil)) }
end
{% endhighlight %}

Usage of such scope is straightforward:

{% highlight ruby %}
# models/admin_user.rb
def managed_presentations
  if superadmin?
    Presentation
  else
    Presentation.unassigned_or_assigned_to conferences
  end
end
{% endhighlight %}

I'll definitely consider using Squeel whenever I'll need to
write complex query.
