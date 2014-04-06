$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require "blog"

namespace :post do

  # Tags separated with single space character
  desc 'Create new post'
  task :new, :title, :tags do |_, args|
    Blog::Post.create(args.title, args.tags.split)
  end

  desc 'Remove post'
  task :rm, :title do |_, args|
    Blog::Post.delete(args.title)
  end

  desc 'Rename post'
  task :rename, :old_title, :new_title do |_, args|
    Blog::Post.rename(args.old_title, args.new_title)
  end

end

namespace :tag do

  desc 'Create new tag'
  task :new, :tag do |_, args|
    Blog::Tag.create(args.tag)
  end

  desc 'Remove tag'
  task :rm, :tag do |_, args|
    Blog::Tag.delete(args.tag)
  end

end

namespace :server do

  desc 'Start server'
  task :start do
    system 'jekyll serve --watch --drafts'
  end

end
