$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require "blog"

namespace :post do

  # Tags separated with single space character
  desc 'Create new post'
  task :new, :title, :tags do |t, args|
    Blog::Post.create(args.title, args.tags.split)
  end

  desc 'Remove post'
  task :rm, :title do |t, args|
    Blog::Post.delete(args.title)
  end

end

namespace :tag do

  desc 'Create new tag'
  task :new, :tag do |t, args|
    Blog::Tag.create(args.tag)
  end

  desc 'Remove tag'
  task :rm, :tag do |t, args|
    Blog::Tag.delete(args.tag)
  end

end
