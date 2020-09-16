require "file_utils"

module TFWeb
  module WebServer
    include API::Simulator
    include API::Members
    include API::Auth

    include Config

    Logger           = Logging.with_colors(self)
    UpdateLock       = Mutex.new
    UpdateRequets    = Atomic(Int32).new(0)
    MaxUpdateRequets = 4

    class SiteCloneStatus
      property name = ""
      property success = true
      property exception : Exception | Nil

      def initialize(@name, @success, @exception)
      end
    end

    def self.serve(configfilepath : String)
      Config.load_from_file(configfilepath)

      Logger.info { "Starting server from config at #{configfilepath}" }

      channel_done = Channel(SiteCloneStatus).new

      Config.all.each do |site|
        spawn do
          exception = nil
          sitename = site.name
          begin
            site.prepare_on_fs
            success = true
          rescue exception
            success = false
          end
          channel_done.send(SiteCloneStatus.new(sitename, success, exception))
        end
      end

      Config.all.size.times do
        status = channel_done.receive # wait for all of them.
        if status.success
          Logger.info { "wiki/website/datasite #{status.name} is ready" }
        else
          Logger.error(exception: status.exception.not_nil!) {
            "could not load wiki/website/datasite #{status.name}, please check the config"
          }
        end
      end

      session = Session.new
      Kemal::Session.config do |config|
        config.timeout = session.timeout
        config.engine = Kemal::Session::FileEngine.new({:sessions_dir => session.path})
        config.secret = session.secret
      end

      Kemal.config.port = Config.server_config["port"].to_i32
      Kemal.config.host_binding = Config.server_config["addr"].to_s

      Kemal.config.add_handler RefererMiddleware.new
      Kemal.run
    end

    def self.do200(env, msg)
      env.response.status_code = 200
      env.response.print msg
      env.response.close
    end

    def self.do404(env, msg)
      env.response.status_code = 404
      env.response.print msg
      env.response.close
    end

    private def self.get_readme_path(wiki, filename)
      path = File.join(wiki.path, wiki.srcdir)
      topfilename = File.basename(path) + ".md"
      potential_readmes = [topfilename, "readme.md", "README.md"]
      potential_readmes.each do |pot_readme|
        filepath = File.join(path, pot_readme)
        if File.exists?(filepath)
          return filepath
        end
      end
    end

    # checks the loaded metadata to find the required md file or image file
    # TODO: phase 2, in future we need to change this to use proper objects: MDDoc, Image, ...
    def self.get_wiki_file_path(wikiname, path)
      wiki = Config.wikis[wikiname]
      full_path = File.join(wiki.path, wiki.srcdir, path.to_s)
      if File.exists?(full_path)
        # good, found on file system
        return full_path
      end

      filename = path.basename
      if filename.downcase == "readme.md"
        # special case for readme
        get_readme_path(wiki, filename)
      else
        # try markdown docs collection
        mddocs = wiki.mdocs
        filesinfo = mddocs.filesinfo
        if filesinfo.has_key?(filename)
          filesinfo[filename].paths[0].as(String) # in decent repo it will be only 1 in this array.
        elsif filesinfo.has_key?(filename.downcase)
          filesinfo[filename.downcase].paths[0].as(String)
        else
          Logger.error { "couldn't find #{filename} in the markdown docs collection of #{wikiname}" }
          nil # return nil if not found, not logger
        end
      end
    end

    def self.serve_wikifile(env, wikiname, path)
      Logger.debug { "Got request for wiki:#{name} url:#{env.params.url}" }
      filepath = self.get_wiki_file_path(wikiname, path)

      if filepath.nil?
        msg = "could not find file '#{path}' in '#{wikiname}'"
        Logger.error { msg }
        do404 env, msg
      else
        # do include macro is possible
        if Config.include_processor.match(filepath)
          content = File.read(filepath)
          new_content = Config.include_processor.apply(content, current_wiki: wikiname)

          if new_content.nil?
            send_file env, filepath
          else
            env.response.content_type = "text/plain"
            return new_content
          end
        else
          send_file env, filepath
        end
      end
    end

    def self.serve_staticsite(env, sitename, path)
      website = Config.websites[sitename]
      website_src_path = File.join(website.path, website.srcdir)
      fullpath = File.join(website_src_path, path.to_s)

      if File.directory?(fullpath)
        fullpath = File.join(fullpath, "index.html")
      end

      if File.exists?(fullpath)
        if fullpath.downcase.ends_with?(".html")
          env.response.content_type = "text/html"
          return Config.include_processor.apply(File.read(fullpath))
        end

        # send normal file
        send_file env, fullpath
      else
        do404 env, "file #{fullpath} is not found"
      end
    end

    def self.serve_datasite(env, sitename, path)
      datasite = Config.datasites[sitename]
      datasite_path = File.join(datasite.path, datasite.srcdir)
      fullpath = File.join(datasite_path, path.to_s)

      if File.exists?(fullpath)
        send_file env, fullpath
      else
        do404 env, "file #{fullpath} is not found"
      end
    end

    private def self.handle_update(env, name, force)
      Logger.info { "trying to update #{name} force? #{force}" }

      if UpdateRequets.get == MaxUpdateRequets
        Logger.info { "maximum update requests reached" }
        return render "src/tfwebserver/views/update/try_again.ecr"
      end

      UpdateRequets.add(1)

      UpdateLock.synchronize do
        if Config.wikis.has_key?(name)
          wiki = Config.wikis[name]
          wiki.repo.try do |arepo|
            arepo.pull(force)
            wiki.prepare_docs
          end
        elsif Config.websites.has_key?(name)
          Config.websites[name].repo.try do |arepo|
            arepo.pull(force)
          end
        elsif Config.blogs.has_key?(name)
          Config.blogs[name].repo.try do |arepo|
            arepo.pull(force)
            Config.blogs[name].prepare_on_fs
          end
        elsif Config.datasites.has_key?(name)
          Config.datasites[name].repo.try do |arepo|
            arepo.pull(force)
          end
        else
          do404 env, "couldn't pull #{name}"
        end

        UpdateRequets.sub(1)
        Logger.info { "updating done, redirecting..." }
        return render "src/tfwebserver/views/update/success.ecr"
      end
    end

    private def self.handle_datafile(env, name, path)
      wiki = Config.wikis[name]
      filepath = File.join(wiki.path, wiki.srcdir, path.to_s)

      basename = File.basename(path)
      ext = File.extname(basename)
      filename_without_ext = File.basename(basename, ext)
      docs = wiki.mdocs
      tomlpath = filename_without_ext + ".toml"
      #   yamlpath = filename_without_ext + ".yaml"
      ymlpath = filename_without_ext + ".yml"
      jsonpath = filename_without_ext + ".json"

      filepathindocs = ""
      env.response.content_type = "application/json"

      env.response.headers["Access-Control-Allow-Origin"] = "*"
      env.response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, OPTIONS"
      env.response.headers["Access-Control-Allow-Headers"] = "Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token"

      content = ""

      if docs.filesinfo.has_key?(tomlpath)
        filepathindocs = docs.filesinfo[tomlpath].paths[0]
        begin
          content = TOML.parse_file(filepathindocs)
          env.response.headers.add("Content-Size", content.size.to_s)

          return do200 env, content.to_json
        rescue exception
          Logger.error(exception: exception) { "error parsing toml data file" }
        end
      elsif docs.filesinfo.has_key?(jsonpath)
        filepathindocs = docs.filesinfo[jsonpath].paths[0]
        begin
          content = File.read(filepathindocs)
          env.response.headers.add("Content-Size", content.size.to_s)

          return do200 env, content
        rescue exception
          Logger.error(exception: exception) { "error parsing reading data file" }
        end
      end
    end

    before_all do |env|
      env.response.headers["Access-Control-Allow-Origin"] = "*"
      env.response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, OPTIONS"
      env.response.headers["Access-Control-Allow-Headers"] = "Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token"
    end

    get "/" do |env|
      wikis = Config.wikis.keys
      websites = Config.websites.keys
      blogs = Config.blogs.keys
      render "src/tfwebserver/views/wiki.ecr"
    end

    get "/:name" do |env|
      name = env.params.url["name"]
      indexpath = Path.new("index.html")
      if Config.wikis.has_key?(name)
        self.serve_wikifile(env, name, indexpath)
      elsif Config.websites.has_key?(name)
        self.serve_staticsite(env, name, indexpath)
      else
        self.do404 env, "file index.html doesn't exist on wiki/website #{name}"
      end
    end

    get "/:name/reload_errors" do |env|
      name = env.params.url["name"]
      if Config.wikis.has_key?(name)
        Config.wikis[name].prepare_docs
      else
        do404 env, "couldn't reload for  #{name}"
      end
    end

    # get template fill in data obj
    get "/:name/templates/:templatename" do |env|
      name = env.params.url["name"]
      if Config.wikis.has_key?(name)
        wikisite = Config.wikis[name]
        templatename = env.params.url["templatename"]

        data = env.params.query["data"]
        # validate its existence, and it won't scale that way, will only work for json endpoints.
        template = wikisite.jinja_env.get_template(templatename)
        text = template.render({"data" => data})
        do200 env, text
      else
        do404 env, "couldn't find wiki #{name}"
      end
    end

    get "/:name/merge_update" do |env|
      name = env.params.url["name"]
      self.handle_update(env, name, false)
    end

    get "/:name/force_update" do |env|
      name = env.params.url["name"]
      self.handle_update(env, name, true)
    end

    get "/:name/*filepath" do |env|
      name = env.params.url["name"]
      path = Path.new(env.params.url["filepath"])
      if Config.wikis.has_key?(name)
        if [".toml", ".json"].includes?(path.extension)
          self.handle_datafile(env, name, path)
        else
          self.serve_wikifile(env, name, path)
        end
      elsif Config.websites.has_key?(name)
        self.serve_staticsite(env, name, path)
      elsif Config.datasites.has_key?(name)
        self.serve_datasite(env, name, path)
      else
        self.do404 env, "file #{path} doesn't exist on wiki/website #{name}"
      end
    end

    get "/:name/logout" do |env|
      env.session.destroy
      "You have been logged out."
    end
  end
end
