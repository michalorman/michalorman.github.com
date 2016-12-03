---
layout: post
tags: [rails, activerecord, rspec]
---
Consider following scenario. Your domain consist of profile model
that belongs to user model, and you want to assure that once user is
being created appropriate profile is being created for this user, therefore
there are no "profile-less" users. You can easily implement such
feature using
[Active Record's callbacks](http://guides.rubyonrails.org/active_record_validations_callbacks.html#available-callbacks):

{% highlight ruby %}
class User < ActiveRecord::Base
  has_one :profile

  before_create :build_profile
end

class Profile < ActiveRecord::Base
  belongs_to :user
  validates :user, :presence => true
end
{% endhighlight %}

Now you want to write profile specification that checks if profile
can be successfully saved given a user. You can implement it like
this:

{% highlight ruby %}
describe Profile do
  context 'with user' do
    let(:user) { create :user }
    subject(:profile) { build :profile, user: user }

    it 'changes the count of profiles once saved' do
      expect { profile.save! }.to change { Profile.count }.by(1)
    end
  end
end
{% endhighlight %}

Note usage of
[FactoryGirl](https://github.com/thoughtbot/factory_girl) instead of
fixtures.

If you run this test it will fail:

{% highlight bash %}
Failures:

  1) Profile with user changes the count of profiles once saved
     Failure/Error: expect { profile.save! }.to change { Profile.count }.by(1)
       result should have been changed by 1, but was changed by 2
{% endhighlight %}

The `save!` method is called once, however it looks that we've got 2
`Profile` objects being saved. How could it be?

The problem is caused because `let` and `subject` in RSpec are lazily
evaluated. This is what happened. First `Profile.count` is evaluated
to fetch its current value (before it is changed). Next the expect
block is evaluated. In this block we call `profile` which build the
`Profile` object. While building profile `user` is called which
creates the user. However `User` model has a callback creating new
profile, here first profile is being saved. Next we call `save!` on just
constructed profile saving second profile instance. Now
`Profile.count` returns 2 instead of expected 1.

To fix the issue we need to force RSpec not to lazily evaluate
creation of user object. We can do this using `let!` method:

{% highlight ruby %}
let!(:user) { create :user }
{% endhighlight %}
