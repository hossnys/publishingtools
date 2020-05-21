module TFWeb
  module API
    module BloggingHelpers
      class SearchResult < Utils::JSON::Base
        include JSON::Serializable

        property type = ""
        property slug = ""
        property title = ""
        property blog_name = ""
      end

      def get_blogsite(name)
        TFWeb::Config.blogs[name]
      end

      def get_blog(name)
        get_blogsite(name).blog.not_nil!
      end

      def blog_exists?(name)
        TFWeb::Config.blogs.has_key?(name)
      end

      def get_all_blog_names
        TFWeb::Config.blogs.keys
      end

      def get_all_blogs
        get_all_blog_names.map { |name| get_blog(name) }
      end

      def get_metadata(blog_name)
        get_blog(blog_name).metadata.not_nil!
      end

      def get_posts(blog_name)
        get_blog(blog_name).posts || [] of TFWeb::Blogging::Post
      end

      def get_pages(blog_name)
        get_blog(blog_name).pages || [] of TFWeb::Blogging::Post
      end

      def get_post_by_slug(blog_name, slug)
        posts = get_posts(blog_name)
        ret = TFWeb::Blogging::Post.new_empty

        posts.each do |post|
          if post.slug == slug
            ret = post
          end
        end

        ret
      end

      def get_tags(blog_name)
        posts = get_posts(blog_name)
        tags = Set(String).new

        posts.each do |post|
          post_tags = post.tags || [] of String

          if post_tags.is_a?(String)
            post_tags = post_tags.split(",")
          end

          post_tags.each do |tag|
            tags << tag.strip
          end
        end

        tags
      end

      def find_posts(posts, query)
        results = [] of TFWeb::Blogging::Post
        posts = posts || [] of TFWeb::Blogging::Post

        posts.each do |post|
          if post.content_with_meta.downcase.includes?(query.downcase)
            results << post
          end
        end

        results
      end

      def new_search_result(blog_name, type, post)
        r = SearchResult.new_empty
        r.blog_name = blog_name.not_nil!
        r.type = type

        r.slug = post.slug.not_nil!
        r.title = post.title.not_nil!

        r
      end

      def search(blog_name, query)
        results = [] of SearchResult

        if blog_name.nil?
          blogs = get_all_blogs()
        else
          blogs = [get_blog(blog_name)]
        end

        blogs.each do |blog|
          blog = blog.not_nil!

          posts = find_posts(blog.posts, query)
          pages = find_posts(blog.pages, query)

          posts.each do |post|
            results << new_search_result(blog.name, "posts", post)
          end

          pages.each do |post|
            results << new_search_result(blog.name, "pages", post)
          end
        end

        results
      end
    end

    module Blogging
      extend BloggingHelpers

      BLOG_API_BASE_URL = "/api/blog"

      post BLOG_API_BASE_URL do |env|
        env.response.content_type = "application/json"
        blog_names = get_all_blogs.map &.name
        blog_names.to_json
      end

      post "#{BLOG_API_BASE_URL}/metadata" do |env|
        env.response.content_type = "application/json"
        params = env.params.json
        if params.has_key?("blog_name")
          blog_name = env.params.json["blog_name"].as(String)
          get_metadata(blog_name).to_json
        else
          env.response.status_code = 400
          "blog name is not provided"
        end
      end

      post "#{BLOG_API_BASE_URL}/posts" do |env|
        env.response.content_type = "application/json"
        blog_name = env.params.json["blog_name"].as(String)
        get_posts(blog_name).to_json
      end

      post "#{BLOG_API_BASE_URL}/post" do |env|
        env.response.content_type = "application/json"
        blog_name = env.params.json["blog_name"].as(String)
        slug = env.params.json["slug"].as(String)
        get_post_by_slug(blog_name, slug).to_json
      end

      post "#{BLOG_API_BASE_URL}/pages" do |env|
        env.response.content_type = "application/json"
        blog_name = env.params.json["blog_name"].as(String)
        get_pages(blog_name).to_json
      end

      post "#{BLOG_API_BASE_URL}/tags" do |env|
        env.response.content_type = "application/json"
        blog_name = env.params.json["blog_name"].as(String)
        get_tags(blog_name).to_json
      end

      post "#{BLOG_API_BASE_URL}/search" do |env|
        env.response.content_type = "application/json"
        blog_name = env.params.json["blog_name"].as(String)
        query = env.params.json["query"].as(String)
        search(blog_name, query).to_json
      end
    end
  end
end
