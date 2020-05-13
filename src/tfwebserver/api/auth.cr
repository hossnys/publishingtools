module TFWeb
  module API
    module Auth
      @@OAUTH_URL = "https://oauth.threefold.io"
      @@REDIRECT_URL = "https://login.threefold.me"
      @@wikis = Hash(String, Wiki).new

      before_get "/:name/" do |env|
        name = env.params.url["name"]
        if @@wikis.has_key?(name)
          if @@wikis[name].auth == true && env.session.bool?("auth") != true
            env.session.string("request-uri", env.request.path)
            env.redirect "/auth/login"
          end
        end
      end

      get "/auth/login" do |env|
        state = UUID.random.to_s.gsub('-', "")
        env.session.string("state", state)
        res = HTTP::Client.get "#{@@OAUTH_URL}/pubkey"
        if !res.success?
          env.response.status_code = 500
          env.response.print "Unexpected error while contacting Oauth server, error code was #{res.status_code}"
        end
        data = JSON.parse(res.body)
        data["publickey"].to_s
        params = {
          "state":       state,
          "appid":       env.request.headers["host"],
          "scope":       {"user": true, "email": true}.to_json,
          "redirecturl": "/auth/callback",
          "publickey":   data["publickey"].to_s,
        }
        params = HTTP::Params.encode(params)
        env.redirect "#{@@REDIRECT_URL}?#{params}"
      end

      get "/auth/callback" do |env|
        data = env.params.query["signedAttempt"]
        state = env.session.string?("state") || ""
        res = HTTP::Client.post("#{@@OAUTH_URL}/verify", form: {"signedAttempt" => data, "state" => state})
        if !res.success?
          env.response.status_code = res.status_code
          env.response.print "Oauth server aborted and returned with: #{res.status_message}"
        end
        body = JSON.parse(res.body)
        env.session.string("username", body["username"].to_s)
        env.session.string("email", body["email"].to_s)
        env.session.bool("auth", true)
        env.redirect env.session.string("request-uri")
      end
    end
  end
end
