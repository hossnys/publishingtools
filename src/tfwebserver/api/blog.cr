module TFWeb
  module API
    module Blogging
      BLOG_BASE_URL = "/api/blog"

      get BLOG_BASE_URL do |env|
        env.response.content_type = "application/json"

        blogs = TFWeb::WebServer.blogs.map { |k, blog| blog.blog }
        blogs.to_json
      end
    end
  end
end
