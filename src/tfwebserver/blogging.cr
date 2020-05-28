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

        unless TFWeb::Config.blogs.has_key?(blog_name)
          # get from referer if set
          if env.request.headers.has_key?("Referer")
            referer = env.request.headers["Referer"]
            referer = URI.parse env.request.headers["Referer"]
            parts = referer.path.split('/')
            begin
              blog_name = parts[2]
              pathparts = [blog_name] + pathparts
            rescue IndexError
            end
          end
        end

        file_path = pathparts[1..-1].join("/")
        Logger.debug { "serving for blog: #{blog_name}, path: #{file_path}" }

        if TFWeb::Config.blogs.has_key?(blog_name)
          blogsite = TFWeb::Config.blogs[blog_name]
          metadata = blogsite.blog.not_nil!.metadata.not_nil!
          asset_dirs = [blogsite.path] + [metadata.assets_dir, metadata.images_dir].map do |dir|
            File.join(blogsite.path, dir)
          end
          foundpath = BLOGGING_INDEX
          asset_dirs.each do |asset_dir|
            asset_path = File.join(asset_dir, file_path)
            if File.exists?(asset_path) && File.file?(asset_path)
              foundpath = asset_path
              break
            end
          end
          send_file env, foundpath
        else
          send_file env, BLOGGING_INDEX
        end
      end
    end
  end
end

require "./blogging/*"
