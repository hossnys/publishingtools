# Matches /hello/kemal
require "kemal"

module TfWiki
  module WikiServer
    @@awalker : TfWiki::Walker = TfWiki::Walker.new
    @@awikipath = ""

    def self.send_from_dirsinfo(env, filename)
      p @@awalker.filesinfo
      puts "will check for #{filename} in the infolist."
      puts @@awalker.filesinfo.keys

      if @@awalker.filesinfo.has_key?(filename)
        firstpath = @@awalker.filesinfo[filename].paths[0] # in decent repo it will be only 1 in this array.
        send_file env, firstpath
      else
        puts "noo."
        env.response.status_code = 404
        env.response.print "file #{filename} doesn't exist in scanned info."
        env.response.close
      end
    end

    get "/reloadinfo" do |env|
      @@awalker.reload_dirfilesinfo(@@awikipath)
    end
    get "/filesinfo" do |env|
      p @@awalker.filesinfo.keys
      #   p @@awalker.filesinfo
    end
    get "/index.html" do |env|
      puts "Got request.."
      fullpath = File.join(@@awikipath, "index.html")
      send_file env, fullpath
      #   self.send_from_dirsinfo(env, filename)
    end

    get "/index.html/:filename" do |env|
      puts "Got request.."
      filename = env.params.url["filename"]
      filename = File.basename(filename)
      ext = File.extname(filename)

      puts env.request.resource
      if ext == ""
        filename = filename + ".md"
      else
        # images and anyother data..
      end
      self.send_from_dirsinfo(env, filename)
    end

    get "/wiki/:filename" do |env|
      puts "Got request.."
      filename = env.params.url["filename"]
      filename = File.basename(filename)
      ext = File.extname(filename)

      puts env.request.resource
      if ext == ""
        filename = filename + ".md"
      else
        # images and anyother data..
      end
      self.send_from_dirsinfo(env, filename)
    end

    get "/:filepath" do |env|
      puts "/:file path request "
      puts env.request.resource
      filepath = env.params.url["filepath"]
      unless File.exists?(filepath)
        env.response.status_code = 404
        env.response.print "file #{filepath} doesn't exist."
        env.response.close
      end
      self.send_from_dirsinfo(env, filepath)
    end

    def self.setup(wikipath : String, walker : TfWiki::Walker)
      @@awikipath = wikipath
      @@awalker = walker
      puts "created server.."
    end

    def self.serve
      puts "Starting kemal server"
      Kemal.run
    end
  end
end
