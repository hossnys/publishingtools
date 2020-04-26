# Matches /hello/kemal
require "kemal"

module TFWeb
  class WebServer


    def initialize()

      @markdowndocs_collection = Hash(String, TFWeb::MarkdownDocs).new

      @port = 3000    

      path="config.toml" #TODO: see config_example.toml

      if ! File.exists(path)
        puts " - ERROR: cannot find config file, needs to be local to where you start this app, name:'config.toml'"
        exit 1
      end

      File.open(path) do |file|
        config = TOML.parse(file)
      end

      pp config

      #TODO: walk over the config and find the sites (www & wiki)
      #TODO: use the gittools to fetch the information


    end

    get "/:name/update" do |env|
      name = env.params.url["name"]
      msg = " - update the following web/wiki site: #{name}"
      puts msg
      #TODO: use the gittools to update the content
    end        

    #checks the loaded metadata to find the required md file or image file
    #TODO: phase 2, in future we need to change this to use proper objects: MDDoc, Image, ...
    private def send_from_dirsinfo(env, sitename, filename)
      #   p @@awalker.filesinfo
      puts "will check for #{filename} in the infolist."
      mddocs = markdowndocs_collections[sitename]
      puts mddocs.filesinfo.keys

      if mddocs.filesinfo.has_key?(filename)
        firstpath = mddocs.filesinfo[filename].paths[0] # in decent repo it will be only 1 in this array.
        send_file env, firstpath
      elsif mddocs.filesinfo.has_key?(filename.downcase)
        firstpath = mddocs.filesinfo[filename.downcase].paths[0] # in decent repo it will be only 1 in this array.
        send_file env, firstpath
      else
        puts "noo."
        env.response.status_code = 404
        env.response.print "file #{filename} doesn't exist in scanned info."
        env.response.close
      end
    end

    # get "/help" do |env|
    #   env.redirect "/reloadinfo" # redirect to /login page
    # end

    get ":sitename/*" do |env|
      #TODO: needs to check if its a wiki or website, if website just return the file
      # if wiki use the markdownsdocs_collection to find the right collection & find the file (md, image only)
      name = env.params.url["sitename"]
      msg = "Got request.. #{env.params.url}"
      puts msg
      env.response.print msg
    end    

    get "/:sitename/:filepath" do |env|
      #TODO: probably needs to be integrate with above
      msg = " - request: file:#{sitename} url:#{env.params.filepath}"
      puts msg
      puts env.request.resource
      filepath = env.params.url["filepath"]
      unless File.exists?(filepath)
        env.response.status_code = 404
        env.response.print "file #{filepath} doesn't exist."
        env.response.close
      end
      # self.send_from_dirsinfo(env, sitename,filepath)
    end


    # get "/reloadinfo" do |env|
    #   @@awalker.reload_dirfilesinfo(@@awikipath)
    # end
    # get "/filesinfo" do |env|
    #   p @@awalker.filesinfo.keys
    #   #   p @@awalker.filesinfo
    # end

    #returns the main html file, is always the same html file but need to fill in the name of the wiki
    get "/:sitename/index.html" do |env|
      sitename = env.params.url["sitename"]
      msg = "Got request: wiki:#{sitename} url:#{env.params.url}"
      puts msg
      #TODO: need to use template to fill in the wikiname
      #TODO: the index.html needs to be packaged with the server
      # fullpath = File.join(@@awikipath, "index.html")
      fullpath = "files/index.html"
      send_file env, fullpath
    end

    #answer for wiki request, 
    private def wiki_answer(env)
      sitename = env.params.url["sitename"]
      msg = " - request: wiki:#{sitename} url:#{env.params.url}"
      puts msg
      filename = env.params.url["filename"]
      filename = File.basename(filename)
      ext = File.extname(filename)

      puts env.request.resource
      if ext == ""
        filename = filename + ".md"
      else
        # images and anyother data..
      end
      self.send_from_dirsinfo(env, sitename, filename)
    end

    get "/:sitename/index.html/:filename" do |env|
      self.wiki_answer env
    end

    get "/:sitename/wiki/:filename" do |env|
        self.wiki_answer env
    end 



    # TODO: don't renable
    # get "/" do |env|
    #   env.redirect "/index.html"
    # end


    def serve()      
      puts " - start server"
      Kemal.config.port = @port
      Kemal.run
    end
  end
end
