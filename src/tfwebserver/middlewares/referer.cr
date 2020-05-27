module TFWeb
  class RefererMiddleware < Kemal::Handler
    def initialize(
      @wikis : Hash(String, Wiki),
      @websites : Hash(String, Website),
      @blogs : Hash(String, Blog)
    )
    end

    def call(env)
      path = env.request.path
      path_parts = path.strip("/").split("/")
      sitename = path_parts.shift

      # for now until blog UI is updated to serve on / or something
      if sitename == "blog" || sitename == "api"
        return call_next env
      end

      unless @wikis.has_key?(sitename) || @websites.has_key?(sitename)
        if env.request.headers.has_key?("Referer")
          referer = URI.parse env.request.headers["Referer"]
          referer_path = referer.path
          referer_path_parts = referer_path.strip("/").split("/")
          referer_sitename = referer_path_parts.shift

          if @wikis.has_key?(referer_sitename) || @websites.has_key?(referer_sitename)
            #   puts "redirecting for #{referer_sitename} and #{sitename}"
            return env.redirect "/#{referer_sitename}#{path}"
          end
        end
      end

      call_next env
    end
  end
end
