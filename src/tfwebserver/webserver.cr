module TFWeb
  module WebServer
    include API::Simulator
    include API::Members
    @@config : TOML::Table?
    @@markdowndocs_collections = Hash(String, MarkdownDocs).new
    @@wikis = Hash(String, Wiki).new
    @@websites = Hash(String, Website).new
    @@datasites = Hash(String, Data).new
    @@include_processor = IncludeProcessor.new

    class MiddleWare < Kemal::Handler
      def initialize(
        @wikis : Hash(String, Wiki),
        @websites : Hash(String, Website)
      )
      end

      def call(env)
        path = env.request.path
        path_parts = path.strip("/").split("/")
        sitename = path_parts.shift

        unless @wikis.has_key?(sitename) || @websites.has_key?(sitename)
          if env.request.headers.has_key?("Referer")
            referer = URI.parse env.request.headers["Referer"]
            referer_path = referer.path
            referer_path_parts = referer_path.strip("/").split("/")
            referer_sitename = referer_path_parts.shift

            if @wikis.has_key?(referer_sitename) || @websites.has_key?(referer_sitename)
              #   puts "redirecting for #{referer_sitename} and #{sitename}"
              return env.redirect "/#{referer_sitename}#{path}" if sitename != "api"
            end
          end
        end

        call_next env
      end
    end

    def self.datasites
      @@datasites
    end

    def self.wikis
      @@wikis
    end

    def self.markdowndocs_collections
      @@markdowndocs_collections
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
      #   p @@config
      @@config.try do |okconfig|
        serverconfig = okconfig["server"].as(Hash)

        okconfig.has_key?("wiki") && okconfig["wiki"].as(Array).each do |wikiel|
          wiki = wikiel.as(Hash)
          #   p wiki
          wikiobj = Wiki.new
          wikiobj.name = wiki["name"].as(String)
          wikiobj.path = wiki["path"].as(String)
          wikiobj.url = wiki["url"].as(String)
          wikiobj.srcdir = wiki["srcdir"].as(String)
          wikiobj.branch = wiki["branch"].as(String)
          wikiobj.branchswitch = wiki["branchswitch"].as(Bool)
          wikiobj.autocommit = wiki["autocommit"].as(Bool)
          wikiobj.environment = wiki.fetch("environment", "").as(String)
          wikiobj.title = wiki.fetch("title", "").as(String)
          @@wikis[wikiobj.name] = wikiobj
        end

        okconfig.has_key?("www") && okconfig["www"].as(Array).each do |websiteel|
          website = websiteel.as(Hash)
          websiteobj = Website.new
          websiteobj.name = website["name"].as(String)
          websiteobj.path = website["path"].as(String)
          websiteobj.url = website["url"].as(String)
          websiteobj.srcdir = website["srcdir"].as(String)
          websiteobj.branch = website["branch"].as(String)
          websiteobj.branchswitch = website["branchswitch"].as(Bool)
          websiteobj.autocommit = website["autocommit"].as(Bool)
          websiteobj.environment = website.fetch("environment", "").as(String)
          websiteobj.title = website.fetch("title", "").as(String)
          @@websites[websiteobj.name] = websiteobj
        end

        okconfig.has_key?("data") && okconfig["data"].as(Array).each do |datael|
          datasite = datael.as(Hash)
          datasiteobj = Data.new
          datasiteobj.name = datasite["name"].as(String)
          datasiteobj.title = datasite["title"].as(String)
          datasiteobj.path = datasite["path"].as(String)
          datasiteobj.url = datasite["url"].as(String)
          datasiteobj.srcdir = datasite["srcdir"].as(String)
          datasiteobj.branch = datasite["branch"].as(String)
          datasiteobj.branchswitch = datasite["branchswitch"].as(Bool)
          datasiteobj.autocommit = datasite["autocommit"].as(Bool)
          datasiteobj.environment = datasite.fetch("environment", "").as(String)
          datasiteobj.title = datasite.fetch("title", "").as(String)
          @@datasites[datasiteobj.name] = datasiteobj
        end

        # p @@wikis
        # p @@websites

        # # TODO: code to validate the uniqueness of wiki, websites names..

        Kemal.config.port = serverconfig["port"].as(Int64).to_i
        Kemal.config.host_binding = serverconfig["addr"].as(String)
      end
    end

    def self.serve(configfilepath : String)
      self.read_config(configfilepath)
      puts "Starting server from config at #{configfilepath}".colorize(:blue)
      channel_done = Channel(String).new

      all = @@wikis.values + @@websites.values + @@datasites.values

      all.each do |site|
        spawn do
          site.prepare_on_fs
          channel_done.send(site.name)
        end
      end

      all.size.times do
        ready = channel_done.receive # wait for all of them.
        puts "wiki/website/datasite #{ready} is ready".colorize(:blue)
      end

      self.prepare_wikis
      Kemal.config.add_handler MiddleWare.new(wikis: @@wikis, websites: @@websites)
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
          new_content = @@include_processor.apply_includes(wikiname, File.read(filepath))
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

    get "/:name/try_update" do |env|
      name = env.params.url["name"]
      self.handle_update(env, name, false)
    end

    get "/:name/force_update" do |env|
      name = env.params.url["name"]
      self.handle_update(env, name, true)
    end
    get "/:name/api/*filepath" do |env|
      filepath = env.params.url["filepath"]
      env.redirect "/api/#{filepath}"
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
  end
end
