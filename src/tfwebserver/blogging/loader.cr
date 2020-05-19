require "time"
require "xml"
require "yaml"

module TFWeb
  module Blogging
    class Document
      META_REGX = /(?s)^\-{3}(.*?)\-{3}\s*$/m

      property meta : PostMeta
      property content : String
      property content_with_meta : String

      def apply_content_processors(content)
        new_content = TFWeb::WebServer.include_processor.apply(content)
        new_content = TFWeb::WebServer.link_expander.apply(new_content)

        if new_content
          new_content
        else
          content
        end
      end

      def initialize(@path : String)
        @content_with_meta = apply_content_processors(File.read(@path))
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

      @path : String

      property metadata : Metadata
      property blog : Blog

      def initialize(@blogsite : TFWeb::Blog)
        @path = @blogsite.path

        metapath = File.join(@path, META_PATH)
        @metadata = Metadata.from_yaml(File.read(metapath))
        @metadata.blog_name = @metadata.blog_name || @blogsite.name

        @blog = Blog.new_empty
        @blog.name = @blogsite.name
        @blog.metadata = metadata
        @blog.posts = create_posts(metadata.posts_dir)
        @blog.pages = create_posts(metadata.pages_dir)
      end

      def remove_date(title)
        title.gsub(/(\d+\-)+/, "")
      end

      def slugify(title)
        # for now
        title.downcase.strip.gsub(" ", "-").gsub(/[^\w-]+/, "")
      end

      def get_excerpt(content, maxlen = 400)
        node = XML.parse_html(Markd.to_html(content || ""))
        node.inner_text[0..maxlen - 1]
      end

      def get_published_date(md_path)
        match = md_path.match(/^(\d+\-\d+\-\d+)/)
        unless match.nil?
          match[0]
        else
          Time.utc.to_s("%Y-%m-%d")
        end
      end

      def create_posts(base_dir)
        posts = [] of Post

        posts_path = File.join(@path, base_dir)
        if Dir.exists?(posts_path)
          list_files(posts_path, ".md") do |md_path|
            document = Document.new(File.join(posts_path, md_path))

            post = Post.from_yaml(document.meta.to_yaml)
            title = post.title || remove_date(md_path)

            post.title = title
            post.published_at = post.published_at || get_published_date(title)
            post.author = post.author || @metadata.author_name
            post.email = post.email || @metadata.author_email

            post.content = document.content
            post.content_with_meta = document.content_with_meta
            post.slug = slugify(title)
            post.excerpt = get_excerpt(post.content)

            post.tags.try do |notniltags|
              if notniltags.is_a?(String)
                post.tags = notniltags.split(",").map &.strip
              elsif notniltags.is_a?(Array)
                post.tags = notniltags.map &.strip
              end
            end
            post.tags = post.tags || [] of String

            posts << post
          end
        end

        posts
      end
    end
  end
end
