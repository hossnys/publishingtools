module TFWeb
  class RefererMiddleware < Kemal::Handler
    def call(env)
      path = env.request.path
      path_parts = path.strip("/").split("/")
      sitename = path_parts.shift

      # for now until blog UI is updated to serve on / or something
      if sitename == "blog" || sitename == "api"
        return call_next env
      end

      unless Config.wikis.has_key?(sitename) || Config.websites.has_key?(sitename) || Config.datasites.has_key?(sitename)
        if env.request.headers.has_key?("Referer")
          referer = URI.parse env.request.headers["Referer"]
          referer_path = referer.path
          referer_path_parts = referer_path.strip("/").split("/")
          referer_sitename = referer_path_parts.shift

          if Config.wikis.has_key?(referer_sitename) || Config.websites.has_key?(referer_sitename)
            return env.redirect "/#{referer_sitename}#{path}"
          end
        end
      end

      call_next env
    end
  end
end
