require "file_utils"

module TFWeb
  module WebServer
    include API::Simulator
    include API::Members
    include API::Auth
    @@config : TOML::Table?
    @@markdowndocs_collections = Hash(String, MarkdownDocs).new
    @@wikis = Hash(String, Wiki).new
    @@websites = Hash(String, Website).new
    @@datasites = Hash(String, Data).new
    @@blogs = Hash(String, Blog).new
    @@include_processor = IncludeProcessor.new
    @@link_expander = LinkExpander.new

    def self.get_websites
      @@websites
    end

    def self.get_wikis
      @@wikis
    end

    class MiddleWare < Kemal::Handler
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

    def self.config
      @@config
    end

    def self.websites
      @@websites
    end

    def self.datasites
      @@datasites
    end

    def self.wikis
      @@wikis
    end

    def self.blogs
      @@blogs
    end

    def self.markdowndocs_collections
      @@markdowndocs_collections
    end

    def self.include_processor
      @@include_processor
    end

    def self.link_expander
      @@link_expander
    end

    def self.prepare_wiki(wiki : Wiki)
      # TODO: handle the url if path is empty
      markdowndocs = MarkdownDocs.new(File.join(wiki.path, wiki.srcdir))
      begin
        markdowndocs.checks_dups_and_fix
      rescue exception
        puts "error happened #{exception}".colorize(:red)
      end
      @@markdowndocs_collections[wiki.name] = markdowndocs
    end

    def self.prepare_wikis
      @@wikis.values.each do |wiki|
        prepare_wiki(wiki)
      end
    end

    def self.read_config(configfilepath)
      @@config = TOML.parse_file(configfilepath)
      # p @@config
      @@config.try do |okconfig|
        serverconfig = okconfig["server"].as(Hash)
        okconfig.has_key?("group") && okconfig["group"].as(Array).each do |groupel|
          group = groupel.as(Hash)
          aclgroup = ACLGroup.new
          aclgroup.name = group["name"].as(String)
          aclgroup.description = group.fetch("description", "").as(String)
          # TODO: can be better?
          group["users"].as(Array).each do |u|
            threebotuser = u.as(String)
            unless threebotuser.ends_with?(".3bot")
              threebotuser += ".3bot"
            end
            aclgroup.users << threebotuser
          end
          aclgroup.save
        end

        okconfig.has_key?("wiki") && okconfig["wiki"].as(Array).each do |wikiel|
          wiki = Wiki.from_json(wikiel.as(Hash).to_json)
          @@wikis[wiki.name] = wiki
        end

        okconfig.has_key?("www") && okconfig["www"].as(Array).each do |websiteel|
          website = Website.from_json(websiteel.as(Hash).to_json)
          @@websites[website.name] = website
        end

        okconfig.has_key?("data") && okconfig["data"].as(Array).each do |datael|
          datasite = Data.from_json(datael.as(Hash).to_json)
          @@datasites[datasite.name] = datasite
        end

        okconfig.has_key?("blog") && okconfig["blog"].as(Array).each do |blogel|
          blog = Blog.from_json(blogel.as(Hash).to_json)
          @@blogs[blog.name] = blog
        end

        # TODO: code to validate the uniqueness of wiki, websites names..
        Kemal.config.port = serverconfig["port"].as(Int64).to_i
        Kemal.config.host_binding = serverconfig["addr"].as(String)
      end
    end

    class SiteCloneStatus
      property name = ""
      property success = true
      property errmsg = ""
    end

    def self.serve(configfilepath : String)
      self.read_config(configfilepath)
      puts "Starting server from config at #{configfilepath}".colorize(:blue)
      channel_done = Channel(SiteCloneStatus).new

      all = @@wikis.values + @@websites.values + @@datasites.values + @@blogs.values

      all.each do |site|
        spawn do
          success = true
          errmsg = ""
          sitename = site.name
          begin
            site.prepare_on_fs
          rescue exception
            errmsg = "#{exception}"
            success = false
          end
          ssc = SiteCloneStatus.new
          ssc.name = site.name
          ssc.errmsg = errmsg
          ssc.success = success
          channel_done.send(ssc)
        end
      end

      all.size.times do
        ssc = channel_done.receive # wait for all of them.
        ready = ssc.success
        name = ssc.name
        if ready == true
          puts "wiki/website/datasite #{name} is ready".colorize(:green)
        else
          puts "wiki/website/datasite #{name} failed #{ssc.errmsg}".colorize(:red)
        end
      end

      self.prepare_wikis

      # at this point ~/tfweb is created

      secret_file_path = Path["~/tfweb/session_secret"].expand(home: true).to_s
      session_dir_path = Path["~/tfweb/session_data"].expand(home: true).to_s
      unless File.exists?(session_dir_path)
        FileUtils.mkdir_p(session_dir_path)
      end
      secret = ENV.fetch("SESSION_SECRET", "")
      if File.exists?(secret_file_path)
        secret = File.read(secret_file_path)
      else
        if secret == ""
          secret = Random::Secure.hex(64)
          File.write(secret_file_path, secret)
        end
      end
      Dir.mkdir_p("session_data")
      Kemal::Session.config do |config|
        config.timeout = 7.days
        config.engine = Kemal::Session::FileEngine.new({:sessions_dir => session_dir_path})
        config.secret = secret
      end

      Kemal.config.add_handler MiddleWare.new(wikis: @@wikis, websites: @@websites, blogs: @@blogs)
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
    def self.get_wiki_file_path(wikiname, filename)
      wiki = @@wikis[wikiname]
      full_path = File.join(wiki.path, wiki.srcdir, filename)
      if File.exists?(full_path)
        # good, found on file system
        return full_path
      end

      if filename.downcase == "readme.md"
        # special case for readme
        get_readme_path(wiki, filename)
      else
        # try markdown docs collection
        mddocs = @@markdowndocs_collections[wikiname]
        filesinfo = mddocs.filesinfo
        if filesinfo.has_key?(filename)
          filesinfo[filename].paths[0].as(String) # in decent repo it will be only 1 in this array.
        elsif filesinfo.has_key?(filename.downcase)
          filesinfo[filename.downcase].paths[0].as(String)
        else
          puts "couldn't find #{filename} in the markdowndocs_collection of #{wikiname}".colorize(:red)
        end
      end
    end

    def self.serve_wikifile(env, wikiname, filename)
      msg = "Got request for wiki:#{name} url:#{env.params.url}"

      filepath = self.get_wiki_file_path(wikiname, filename)

      if filepath.nil?
        puts msg.colorize :red
        do404 env, msg
      else
        # do include macro is possible
        if @@include_processor.match(filepath)
          content = File.read(filepath)
          new_content = @@include_processor.apply(content, current_wiki: wikiname)
          new_content = @@link_expander.apply(new_content)

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

    def self.serve_staticsite(env, sitename, filename)
      website = @@websites[sitename]
      website_src_path = File.join(website.path, website.srcdir)
      path = File.join(website_src_path, filename)

      if File.directory?(path)
        path = File.join(path, "index.html")
      end

      if File.exists?(path)
        send_file env, path
      else
        do404 env, "file #{path} is not found"
      end
    end

    private def self.handle_update(env, name, force)
      puts "trying to update #{name} force? #{force}".colorize(:blue)
      if @@wikis.has_key?(name)
        @@wikis[name].repo.try do |arepo|
          arepo.pull(force)
          @@markdowndocs_collections[name].checks_dups_and_fix
        end
      elsif @@websites.has_key?(name)
        @@websites[name].repo.try do |arepo|
          arepo.pull(force)
        end
      elsif @@blogs.has_key?(name)
        @@blogs[name].repo.try do |arepo|
          arepo.pull(force)
          @@blogs[name].prepare_on_fs
        end
      else
        do404 env, "couldn't pull #{name}"
      end
    end

    private def self.handle_datafile(env, name, path)
      wiki = @@wikis[name]
      filepath = File.join(wiki.path, wiki.srcdir, path.to_s)

      basename = File.basename(path)
      ext = File.extname(basename)
      filename_without_ext = File.basename(basename, ext)
      docs = @@markdowndocs_collections[name]
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
          puts "#{exception}".colorize(:red)
        end
      elsif docs.filesinfo.has_key?(jsonpath)
        filepathindocs = docs.filesinfo[jsonpath].paths[0]
        begin
          content = File.read(filepathindocs)
          env.response.headers.add("Content-Size", content.size.to_s)

          return do200 env, content
        rescue exception
          puts "#{exception}".colorize(:red)
        end
      end
    end

    before_all do |env|
      env.response.headers["Access-Control-Allow-Origin"] = "*"
      env.response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, OPTIONS"
      env.response.headers["Access-Control-Allow-Headers"] = "Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token"
    end

    get "/" do |env|
      wikis = @@wikis.keys
      websites = @@websites.keys
      blogs = @@blogs.keys
      render "src/tfwebserver/views/wiki.ecr"
    end

    get "/:name" do |env|
      name = env.params.url["name"]
      if @@markdowndocs_collections.has_key?(name)
        self.serve_wikifile(env, name, "index.html")
      elsif @@websites.has_key?(name)
        self.serve_staticsite(env, name, "index.html")
      else
        self.do404 env, "file index.html doesn't exist on wiki/website #{name}"
      end
    end

    get "/:name/reload_errors" do |env|
      name = env.params.url["name"]
      if @@wikis.has_key?(name)
        @@markdowndocs_collections[name].checks_dups_and_fix
      else
        do404 env, "couldn't reload for  #{name}"
      end
    end

    # get template fill in data obj
    get "/:name/templates/:templatename" do |env|
      name = env.params.url["name"]
      if @@wikis.has_key?(name)
        wikisite = @@wikis[name]
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
      filepath = env.params.url["filepath"]
      if @@wikis.has_key?(name)
        path = Path.new(filepath)
        if [".toml", ".json"].includes?(path.extension)
          self.handle_datafile(env, name, path)
        else
          self.serve_wikifile(env, name, path.basename)
        end
      elsif @@websites.has_key?(name)
        self.serve_staticsite(env, name, filepath)
      else
        self.do404 env, "file #{filepath} doesn't exist on wiki/website #{name}"
      end
    end

    get "/:name/logout" do |env|
      env.session.destroy
      "You have been logged out."
    end
  end
end
