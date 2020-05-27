module TFWeb
  module Blogging
    # TODO: make this a genric way to serve single page apps

    BLOGGING_BASE_URL = "/blog"
    BLOGGING_BASE_DIR = "src/tfwebserver/static/blog"
    BLOGGING_INDEX    = File.join(BLOGGING_BASE_DIR, "index.html")

    get "#{BLOGGING_BASE_URL}/" do |env|
      send_file env, BLOGGING_INDEX
    end

    get "#{BLOGGING_BASE_URL}/*filepath" do |env|
      path = env.params.url["filepath"]
      full_path = File.join(BLOGGING_BASE_DIR, path)
      if File.exists?(full_path)
        send_file env, full_path
      else
        pathparts = path.split('/')
        blog_name = pathparts[0]
        file_path = pathparts[1..-1].join("/")
        if TFWeb::Config.blogs.has_key?(blog_name)
          blogsite = TFWeb::Config.blogs[blog_name]
          asset_path = File.join(blogsite.path, file_path)
          if File.exists?(asset_path) && File.file?(asset_path)
            send_file env, asset_path
          else
            send_file env, BLOGGING_INDEX
          end
        else
          send_file env, BLOGGING_INDEX
        end
      end
    end
  end
end

require "./blogging/*"
