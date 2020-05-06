require "yaml"

module TFWeb
  module Blogging
    class Metadata < Utils::YAML::Base
      include YAML::Serializable
      include JSON::Serializable

      property blog_name : String? = ""
      property blog_title : String? = ""
      property blog_description : String? = ""
      property author_name : String? = ""
      property author_email : String? = ""
      property author_image : String? = ""
      property base_url : String? = ""
      property url : String? = ""
      property posts_dir : String = "posts"
      property pages_dir : String = "pages"
      property github_username : String? = ""
      property github_repo_url : String? = ""

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

      property title : String? = ""
      property author_name : String? = ""
      property author_email : String? = ""
      property author_image : String? = ""
      property post_image : String? = ""
      property description : String? = ""
      property tags : Array(String)? | String?
    end

    class Post < PostMeta
      include YAML::Serializable
      include JSON::Serializable

      property slug : String? = ""
      property excerpt : String? = ""
      property published_at : String? = ""
      property content : String? = ""
      property content_with_meta : String? = ""
    end

    class Link < Utils::YAML::Base
      include YAML::Serializable
      include JSON::Serializable

      property title = ""
      property link = ""

      property page : String? = ""
      property faclass : String = ""
    end

    class Blog < Utils::YAML::Base
      include YAML::Serializable
      include JSON::Serializable

      property name : String? = ""
      property git_repo_url : String? = ""

      property metadata : Metadata?

      property posts : Array(Post)?
      property pages : Array(Post)?
    end
  end
end
