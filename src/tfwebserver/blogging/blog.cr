require "yaml"

module TFWeb
  module Blogging
    class Metadata
      include YAML::Serializable

      @blog_name : String
      @blog_title : String
      @blog_description : String
      @author_name : String
      @author_email : String
      @author_image : String
      @base_url : String
      @url : String
      @posts_dir : String = "posts"
      @github_username : String
      @github_repo_url : String

      @nav_links : Array(Link)
      @sidebar_social_links : Array(Link)
      @sidebar_links : Array(Link)

      @allow_disqus = true
      @allow_navbar = true
      @allow_footer = true

      @posts_per_page : UInt16
    end

    class Blog
      include YAML::Serializable

      @name : String
      @git_repo_url : String

      @metadata : Metadata

      @posts : Array(Post)
      @pages : Array(Post)
    end

    class Post
      include YAML::Serializable

      @title : String
      @slug : String
      @content : String
      @content_with_meta : String
      @published_at : String
      @author_name : String
      @author_email : String
      @author_image : String
      @post_image : String
      @excerpt : String
      @description : String

      @tags : Array(String)
    end

    class Link
      include YAML::Serializable

      @title : String
      @link : String
      @page : String
      @faclass : String
    end
  end
end
