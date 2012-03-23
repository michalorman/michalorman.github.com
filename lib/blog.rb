require 'core_ext'

module Blog
  class Post
    def initialize(title, tags)
      @post_file = "#{timestamp}-#{title.to_file_name}.md"
      @tags = tags
    end

    def create
      @tags.each do |tag|
        Tag.create(tag)
      end
      File.open(File.join("_posts", @post_file), 'w+') do |f|
        f.puts content
      end
      puts "Created post '#@post_file'"
    end

    def self.create(title, tags)
      Post.new(title, tags).create
    end

    private

    def timestamp
      Time.now.strftime('%Y-%m-%d')
    end

    def content
      <<-END
---
layout: post
tags: [#{@tags * ','}]
---
END
    end
  end

  class Tag
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

    def self.create(tag)
      Tag.new(tag).create
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
