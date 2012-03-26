---
layout: post
tags: [ruby, ry, rbenv, rvm]
---
If you already switched to
[rbenv](https://github.com/sstephenson/rbenv) as a lightweight
alternative to RVM you might be interested in another project:
[ry](https://github.com/jayferd/ry) which is supposed to be even more
lightweight. What I'm missing right know is equivalent of rbenv's
local, per-project Ruby version configuration. At least I wasn't able
to find such configuration by examining sources.

The advantage of ry over rbenv is that it is a little more
unobtrusive, is a little easier to install and we do not need to
invoke magic `rehash` command after installing new Ruby or gem
which provides binaries.

You didn't switched from RVM to other lightweight solution? For me there
is really no reason to stick with RVM while gemsets may be effectively
[substituted with Bundler](http://rakeroutes.com/blog/how-to-use-bundler-instead-of-rvm-gemsets/),
as for Ruby version management RVM is to heavy, and it integrates with
environment to much.
