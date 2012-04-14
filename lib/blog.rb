require 'core_ext'

module Blog

  class Post
    include FileUtils

    def initialize(title, tags = nil)
      @post_file = "#{title.to_file_name}.md"
      @tags = tags
    end

    def create
      @tags.each do |tag|
        Tag.create(tag)
      end
      file = "#{timestamp}-#@post_file"
      File.open(File.join("_posts", file), 'w+') do |f|
        f.puts content
      end
      puts "Created post '#{file}'"
    end

    def exist?
      !Dir["_posts/*#@post_file"].empty?
    end

    def delete
      if exist?
        Dir["_posts/*#@post_file"].each do |f|
          puts "Deleting post: #{f}"
          rm f, :verbose => false
        end
      end
    end

    def rename(new_title)
      if exist?
        Dir["_posts/*#@post_file"].each do |f|
          file = "#{timestamp}-#{new_title.to_file_name}.md"
          puts "Renaming post: #{f} to _posts/#{file}"
          mv f, File.join("_posts", file)
        end
      end
    end

    def self.create(title, tags)
      Post.new(title, tags).create
    end

    def self.delete(title)
      Post.new(title).delete
    end

    def self.rename(old_title, new_title)
      Post.new(old_title).rename(new_title)
    end

    private

    def timestamp
      Time.now.strftime('%Y-%m-%d')
    end

    def content
      <<-END
---
layout: post
tags: [#{@tags * ', '}]
---
END
    end
  end

  class Tag
    include FileUtils

    def initialize(tag)
      @tag = tag.to_file_name
      @tag_dir = File.join("tags", @tag)
    end

    def exist?
      File.exist?(@tag_dir)
    end

    def create
      unless exist?
        puts "Creating new tag: #@tag"

        mkdir @tag_dir, :verbose => false

        File.open(File.join(@tag_dir, 'index.html'), 'w+') do |f|
          f.puts content
        end
      end
    end

    def delete
      if exist?
        puts "Removing tag: #@tag"
        rmtree @tag_dir, :verbose => false
      end
    end

    def self.create(tag)
      Tag.new(tag).create
    end

    def self.delete(tag)
      Tag.new(tag).delete
    end

    private

    def content
      <<-END
---
layout: tag-posts
tag: #@tag
title: posts tagged with #@tag
---
END
    end
  end
end
