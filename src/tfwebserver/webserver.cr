# Matches /hello/kemal
require "kemal"
require "toml"

module TFWeb
  module WebServer
    @@config : TOML::Table?
    @@markdowndocs_collections = Hash(String, MarkdownDocs).new
    # puts @@markdowndocs_collections
    @@wikis = Hash(String, Wiki).new
    @@websites = Hash(String, Website).new

    def self.prepare_markdowndocs_backend
      @@wikis.each do |k, wiki|
        # puts wiki
        # TODO: handle the url if path is empty
        markdowndocs = MarkdownDocs.new(File.join(wiki.path, wiki.srcdir))
        begin
          markdowndocs.checks_dups_and_fix
        rescue exception
          puts "error happened #{exception}"
        end
        @@markdowndocs_collections[k] = markdowndocs
      end
    end

    def self.read_config(configfilepath)
      @@config = TOML.parse_file(configfilepath)
      #   p @@config
      @@config.try do |okconfig|
        serverconfig = okconfig["server"].as(Hash)

        okconfig.has_key?("wiki") && okconfig["wiki"].as(Array).each do |wikiel|
          wiki = wikiel.as(Hash)
          p wiki
          wikiobj = Wiki.new
          wikiobj.name = wiki["name"].as(String)
          wikiobj.path = wiki["path"].as(String)
          wikiobj.url = wiki["url"].as(String)
          wikiobj.srcdir = wiki["srcdir"].as(String)
          wikiobj.branch = wiki["branch"].as(String)
          wikiobj.branchswitch = wiki["branchswitch"].as(Bool)
          wikiobj.autocommit = wiki["autocommit"].as(Bool)
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
          @@websites[websiteobj.name] = websiteobj
        end

        p @@wikis
        p @@websites

        # # TODO: code to validate the uniqueness of wiki, websites names..

        Kemal.config.port = serverconfig["port"].as(Int64).to_i
        Kemal.config.host_binding = serverconfig["addr"].as(String)
      end
    end

    def self.serve(configfilepath : String)
      self.read_config(configfilepath)
      puts "Starting server from config at #{configfilepath}"
      channel_done = Channel(String).new

      @@wikis.each do |k, w|
        spawn do
          w.prepare_on_fs
          w.prepare_index
          channel_done.send(w.name)
        end
      end
      @@websites.each do |k, w|
        spawn do
          w.prepare_on_fs
          channel_done.send(w.name)
        end
      end
      (@@websites.size + @@wikis.size).times do
        ready = channel_done.receive # wait for all of them.
        puts "wiki/website #{ready} is ready"
      end
      self.prepare_markdowndocs_backend

      Kemal.run
    end

    # checks the loaded metadata to find the required md file or image file
    # TODO: phase 2, in future we need to change this to use proper objects: MDDoc, Image, ...
    def self.send_from_dirsinfo(env, wikiname, filename)
      #   p @@awalker.filesinfo
      puts "will check for #{filename} in the infolist. of #{wikiname}"
      mddocs = @@markdowndocs_collections[wikiname]
      filesinfo = mddocs.filesinfo
      #   puts filesinfo.keys

      if filesinfo.has_key?(filename)
        firstpath = filesinfo[filename].paths[0] # in decent repo it will be only 1 in this array.
        send_file env, firstpath
      elsif filesinfo.has_key?(filename.downcase)
        firstpath = filesinfo[filename.downcase].paths[0] # in decent repo it will be only 1 in this array.
        send_file env, firstpath
      else
        # TODO: should try to reload before giving 404?
        puts "couldn't find #{filename} in the markdowndocs_collection of #{wikiname}"
        env.response.status_code = 404
        env.response.print "file #{filename} doesn't exist in scanned info."
        env.response.close
      end
    end

    def self.serve_wikifile(env, wikiname, filename)
      msg = "Got request for wiki:#{name} url:#{env.params.url}"
      self.send_from_dirsinfo(env, wikiname, filename)
    end

    def self.serve_staticsite(env, sitename, filename)
      website = @@websites[sitename]
      website_src_path = File.join(website.path, website.srcdir)
      fullpath = File.join(website_src_path, filename)
      send_file env, fullpath
    end

    def self.do404(env, msg)
      env.response.status_code = 404
      env.response.print msg
      env.response.close
    end

    # returns the main html file, is always the same html file but need to fill in the name of the wiki
    get "/:name" do |env|
      name = env.params.url["name"]
      env.redirect "#{name}/index.html"
    end

    private def self.handle_update(env, name, force)
      puts "trying to update #{name} force? #{force}"
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

    get "/:name/try_update" do |env|
      name = env.params.url["name"]
      self.handle_update(env, name, false)
    end
    get "/:name/force_update" do |env|
      name = env.params.url["name"]
      self.handle_update(env, name, true)
    end

    get "/:name/index.html" do |env|
      name = env.params.url["name"]
      #   puts @@markdowndocs_collections.keys
      if @@markdowndocs_collections.has_key?(name)
        self.serve_wikifile(env, name, "index.html")
      elsif @@websites.has_key?(name)
        self.serve_staticsite(env, name, "index.html")
      else
        self.do404 env, "file index.html doesn't exist on wiki/website #{name}"
      end
    end

    # get "/:name/index.html/:filename" do |env|
    #   name = env.params.url["name"]
    #   filename = env.params.url["filename"]
    #   puts @@markdowndocs_collections.keys
    #   if @@markdowndocs_collections.has_key?(name)
    #     self.serve_wikifile(env, name, filename)
    #   elsif @@websites.has_key?(name)
    #     self.serve_staticsite(env, name, filename)
    #   else
    #     self.do404 env, "file #{filename} doesn't exist on wiki/website #{name}"
    #   end
    # end

    get "/:name/index.html/_sidebar.md" do |env|
      name = env.params.url["name"]
      fullpath = File.join(@@wikis[name].path, @@wikis[name].srcdir, "_sidebar.md")
      send_file env, fullpath
    end
    get "/:name/*filepath" do |env|
      puts "invoking this one.."
      name = env.params.url["name"]
      filepath = env.params.url["filepath"]
      puts @@markdowndocs_collections.keys
      if @@markdowndocs_collections.has_key?(name)
        self.serve_wikifile(env, name, File.basename(filepath))
      elsif @@websites.has_key?(name)
        self.serve_staticsite(env, name, filepath)
      else
        self.do404 env, "file #{filepath} doesn't exist on wiki/website #{name}"
      end
    end

    get "/:name/index.html/*filepath" do |env|
      name = env.params.url["name"]
      filepath = env.params.url["filepath"]
      filename = File.basename(filepath)
      # puts @@markdowndocs_collections.keys
      if @@markdowndocs_collections.has_key?(name)
        self.serve_wikifile(env, name, filename)
      elsif @@websites.has_key?(name)
        self.serve_staticsite(env, name, filename)
      else
        self.do404 env, "file #{filename} doesn't exist on wiki/website #{name}"
      end
    end
  end

  #     get "/:name/update" do |env|
  #       name = env.params.url["name"]
  #       msg = " - update the following web/wiki site: #{name}"
  #       puts msg
  #       # TODO: use the gittools to update the content
  #     end

  #     # get "/help" do |env|
  #     #   env.redirect "/reloadinfo" # redirect to /login page
  #     # end

end
