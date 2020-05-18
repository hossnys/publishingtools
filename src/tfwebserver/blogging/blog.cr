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

      property title
      property link

      property page : String?
      property faclass : String?
    end

    class Blog < Utils::YAML::Base
      include YAML::Serializable
      include JSON::Serializable

      property name : String?
      property git_repo_url : String?

      property metadata : Metadata?

      property posts = [] of TFWeb::Blogging::Post
      property pages = [] of TFWeb::Blogging::Post

      private def valid_published_at(s)
        s.split("-").map { |x| true if x.to_i rescue false }.all?
      end

      def posts
        invalid_ones = [] of Post
        valid_ones = [] of Post

        @posts.each do |p|
          if !valid_published_at(p.published_at.not_nil!)
            invalid_ones << p
          else
            valid_ones << p
          end
        end
        sorted = valid_ones.sort_by { |p|
          Time.parse_utc(p.published_at.not_nil!, "%F")
        }
        sorted.reverse!
        sorted.concat invalid_ones

        sorted
      end
    end
  end
end
