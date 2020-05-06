require "yaml"

module TFWeb
  module Blogging
    class Document
      META_REGX = /(?s)^\-{3}(.*?)\-{3}$/m

      property meta : PostMeta
      property content : String
      property content_with_meta : String

      def initialize(@path : String)
        @content_with_meta = File.read(@path)
        match = @content_with_meta.strip.match(META_REGX)

        unless match.nil?
          meta = match[0]
          @meta = PostMeta.from_yaml(meta)
          @content = @content_with_meta.gsub(meta, "")
        else
          @meta = PostMeta.new_empty
          @content = @content_with_meta
        end
      end
    end

    class Loader
      include Utils::FS

      META_PATH = "metadata.yml"

      property blog : Blog

      def initialize(@path : String)
        metapath = File.join(@path, META_PATH)

        @blog = Blog.new_empty
        @blog.metadata = Metadata.from_yaml(File.read(metapath))

        create_posts
        create_pages
      end

      def create_posts
        @blog.posts = [] of Post

        @blog.metadata.try do |metadata|
          posts_path = File.join(@path, metadata.posts_dir)
          list_files(posts_path, ".md") do |md_path|
            document = Document.new(File.join(posts_path, md_path))

            post = Post.from_yaml(document.meta.to_yaml)
            # post.slug = ""
            # post.excerpt = ""
            # post.published_at = ""
            post.content = document.content
            post.content_with_meta = document.content_with_meta
            @blog.posts.try do |posts|
              posts << post
            end
          end
        end
      end

      def create_pages
      end
    end
  end
end
