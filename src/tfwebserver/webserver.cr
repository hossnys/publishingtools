# Matches /hello/kemal
require "kemal"
require "toml"

module TFWeb
  module WebServer
    class Wiki
      property name = ""
      property path = ""
      property url = ""
      property branch = ""
      property branchswitch = false
      property autocommit = false
      property srcdir = "src"

      def prepare_on_fs
      end

      def prepare_index
        destindex = File.join(@path, @srcdir, "index.html")
        # unless File.exists(destindex)
        idx = TFWeb.get_index_for(@name)
        File.write(destindex, idx)
      end
    end

    class Website
      property name = ""
      property path = ""
      property url = ""
      property branch = ""
      property branchswitch = false
      property autocommit = false
      property srcdir = "src"

      def prepare_on_fs
      end
    end

    @@config : TOML::Table?
    @@markdowndocs_collections = Hash(String, TFWeb::MarkdownDocs).new
    puts @@markdowndocs_collections
    @@wikis = Hash(String, Wiki).new
    @@websites = Hash(String, Website).new

    def self.prepare_markdowndocs_backend
      @@wikis.each do |k, wiki|
        # TODO: handle the url if path is empty
        markdowndocs = TFWeb::MarkdownDocs.new(wiki.path)
        markdowndocs.checks_dups_and_fix
        @@markdowndocs_collections[k] = markdowndocs
      end
    end

    def self.read_config(configfilepath)
      @@config = TOML.parse_file(configfilepath)
      #   p @@config
      @@config.try do |okconfig|
        serverconfig = okconfig["server"].as(Hash)

        okconfig["wiki"].as(Array).each do |wikiel|
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
          wikiobj.prepare_on_fs
          wikiobj.prepare_index
          @@wikis[wikiobj.name] = wikiobj
        end
        okconfig["www"].as(Array).each do |websiteel|
          website = websiteel.as(Hash)
          websiteobj = Website.new
          websiteobj.name = website["name"].as(String)
          websiteobj.path = website["path"].as(String)
          websiteobj.url = website["url"].as(String)
          websiteobj.srcdir = website["srcdir"].as(String)
          websiteobj.branch = website["branch"].as(String)
          websiteobj.branchswitch = website["branchswitch"].as(Bool)
          websiteobj.autocommit = website["autocommit"].as(Bool)
          websiteobj.prepare_on_fs
          @@websites[websiteobj.name] = websiteobj
        end

        p @@wikis
        p @@websites

        # # TODO: code to validate the uniqueness of wiki, websites names..

        Kemal.config.port = 3000 # serverconfig["port"].to_s.to_u32 can't cast here? TODO
        Kemal.config.host_binding = serverconfig["addr"].as(String)
      end
    end

    def self.serve(configfilepath : String)
      self.read_config(configfilepath)
      self.prepare_markdowndocs_backend
      puts "Starting server"

      Kemal.run
    end

    # checks the loaded metadata to find the required md file or image file
    # TODO: phase 2, in future we need to change this to use proper objects: MDDoc, Image, ...
    def self.send_from_dirsinfo(env, wikiname, filename)
      #   p @@awalker.filesinfo
      puts "will check for #{filename} in the infolist."
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
        puts "noo."
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
      fullpath = File.join(@@websites[sitename].path, filename)
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

    get "/:name/index.html" do |env|
      name = env.params.url["name"]
      puts "here.."
      puts @@markdowndocs_collections.keys
      if @@markdowndocs_collections.has_key?(name)
        self.serve_wikifile(env, name, "index.html")
      elsif @@websites.has_key?(name)
        self.serve_staticsite(env, name, "index.html")
      else
        self.do404 env, "file index.html doesn't exist on wiki/website #{name}"
      end
    end

    get "/:name/index.html/:filename" do |env|
      name = env.params.url["name"]
      filename = env.params.url["filename"]
      puts @@markdowndocs_collections.keys
      if @@markdowndocs_collections.has_key?(name)
        self.serve_wikifile(env, name, filename)
      elsif @@websites.has_key?(name)
        self.serve_staticsite(env, name, filename)
      else
        self.do404 env, "file #{filename} doesn't exist on wiki/website #{name}"
      end
    end
    get "/:name/index.html/_sidebar.md" do |env|
      name = env.params.url["name"]
      fullpath = File.join(@@wikis[name].path, @@wikis[name].srcdir, "_sidebar.md")
      send_file env, fullpath
    end
    get "/:name/*filepath" do |env|
      puts "invoking this one.."
      name = env.params.url["name"]
      filepath = env.params.url["filepath"]
      if true
        self.serve_staticsite(env, name, filepath)
      else
        self.do404 env, "file #{filepath} doesn't exist on wiki/website #{name}"
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

  #     get ":sitename/*" do |env|
  #       # TODO: needs to check if its a wiki or website, if website just return the file
  #       # if wiki use the markdownsdocs_collection to find the right collection & find the file (md, image only)
  #       name = env.params.url["sitename"]
  #       msg = "Got request.. #{env.params.url}"
  #       puts msg
  #       env.response.print msg
  #     end

  #     get "/:sitename/:filepath" do |env|
  #       # TODO: probably needs to be integrate with above
  #       msg = " - request: file:#{sitename} url:#{env.params.filepath}"
  #       puts msg
  #       puts env.request.resource
  #       filepath = env.params.url["filepath"]
  #       unless File.exists?(filepath)
  #         env.response.status_code = 404
  #         env.response.print "file #{filepath} doesn't exist."
  #         env.response.close
  #       end
  #       # self.send_from_dirsinfo(env, sitename,filepath)
  #     end

  #     # get "/reloadinfo" do |env|
  #     #   @@awalker.reload_dirfilesinfo(@@awikipath)
  #     # end
  #     # get "/filesinfo" do |env|
  #     #   p @@awalker.filesinfo.keys
  #     #   #   p @@awalker.filesinfo
  #     # end

  #     # returns the main html file, is always the same html file but need to fill in the name of the wiki
  #     get "/:sitename/index.html" do |env|
  #       sitename = env.params.url["sitename"]
  #       msg = "Got request: wiki:#{sitename} url:#{env.params.url}"
  #       puts msg
  #       # TODO: need to use template to fill in the wikiname
  #       # TODO: the index.html needs to be packaged with the server
  #       # fullpath = File.join(@@awikipath, "index.html")
  #       fullpath = "files/index.html"
  #       send_file env, fullpath
  #     end

  #     # answer for wiki request,
  #     private def wiki_answer(env)
  #       sitename = env.params.url["sitename"]
  #       msg = " - request: wiki:#{sitename} url:#{env.params.url}"
  #       puts msg
  #       filename = env.params.url["filename"]
  #       filename = File.basename(filename)
  #       ext = File.extname(filename)

  #       puts env.request.resource
  #       if ext == ""
  #         filename = filename + ".md"
  #       else
  #         # images and anyother data..
  #       end
  #       self.send_from_dirsinfo(env, sitename, filename)
  #     end

  #     get "/:sitename/index.html/:filename" do |env|
  #       self.wiki_answer env
  #     end

  #     get "/:sitename/wiki/:filename" do |env|
  #       self.wiki_answer env
  #     end

  #     # TODO: don't renable
  #     # get "/" do |env|
  #     #   env.redirect "/index.html"
  #     # end

  #     def serve
  #       puts " - start server"
  #       Kemal.config.port = @port
  #       Kemal.run
  #     end
  #   end
end
