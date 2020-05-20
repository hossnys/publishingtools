require "yaml"

module TFWeb
  module Blogging
    # TODO: maybe using mapping with default value is better
    # for values that can be omitted but still have a default value?

    class Metadata < Utils::YAML::Base
      include YAML::Serializable
      include JSON::Serializable

      property blog_name : String?
      property blog_title : String?
      property blog_description : String?
      property author_name : String?
      property author_email : String?
      property author_image : String?
      property base_url : String?
      property url : String?

      property posts_dir = "posts"
      property pages_dir = "pages"
      property assets_dir = "assets"
      property images_dir = "assets/images"

      property github_username : String?
      property github_repo_url : String?

      property nav_links : Array(Link)
      property sidebar_social_links : Array(Link)
      property sidebar_links : Array(Link)

      property allow_disqus : Bool? = true
      property allow_navbar : Bool? = true
      property allow_footer : Bool? = true

      property posts_per_page : Int16? = Int16.new(5)
    end

    class PostMeta < Utils::YAML::Base
      include YAML::Serializable
      include JSON::Serializable

      property title : String?
      property author : String?
      property email : String?
      property author_image : String?
      property post_image : String?
      property description : String?
      property tags : Array(String)? | String?
      property published_at : String?
    end

    class Post < PostMeta
      include YAML::Serializable
      include JSON::Serializable

      property slug : String?
      property excerpt = ""
      property content = ""
      property content_with_meta = ""

      def to_s
        "Post #{@title} #{tags} #{published_at}"
      end
    end

    class Link < Utils::YAML::Base
      include YAML::Serializable
      include JSON::Serializable

      @[YAML::Field(emit_null: true)]
      property title = ""

      @[YAML::Field(emit_null: true)]
      property link = ""

      @[YAML::Field(emit_null: true)]
      property page = ""

      @[YAML::Field(emit_null: true)]
      property faclass = ""

      @[YAML::Field(emit_null: true)]
      property colorcode = ""
    end

    class Blog < Utils::YAML::Base
      include YAML::Serializable
      include JSON::Serializable

      property name : String?
      property git_repo_url : String?

      property metadata : Metadata?

      property posts = [] of TFWeb::Blogging::Post
      property pages = [] of TFWeb::Blogging::Post

      def posts
        now = Time.utc
        longest_span = now - Time::UNIX_EPOCH # => Time::Span
        @posts.sort_by do |p|
          begin
            # shortest span
            now - Time.parse_utc(p.published_at.not_nil!, "%F")
          rescue ArgumentError | Time::Format::Error
            longest_span
          end
        end
      end
    end
  end
end
