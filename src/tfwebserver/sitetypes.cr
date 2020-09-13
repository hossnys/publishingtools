require "crinja"
require "crystaltools"

module TFWeb
  class Site
    include JSON::Serializable

    property name = ""
    property title = ""
    property path = ""
    property url = ""
    property branch = ""
    property branchswitch = false
    property autocommit = false
    property srcdir = "src"
    property environment = ""
    property auth = false
    property groups = [] of String
    property aclusers = [] of String

    # @[JSON::Field(ignore: true)]
    # property gitrepo_factory = CrystalTools::GITRepoFactory.new(env: @environment)

    @[JSON::Field(emit_null: true)]
    property domain = ""

    @[JSON::Field(ignore: true)]
    property jinja_env = Crinja.new

    @[JSON::Field(ignore: true)]
    property mdocs = MarkdownDocs.new("")

    @[JSON::Field(ignore: true)]
    property type = ""

    def to_s
      "#{@name} #{@auth} #{@environment} "
    end

    def user_can_access?(username)
      return true if @auth == false
      return true if @groups.size == 0 && @aclusers.size == 0 # if there's no acl.toml too it's public.

      username = username.downcase
      return true if @aclusers.map(&.downcase).includes?(username)

      groups.each do |groupname|
        if Config::GROUPS[groupname].users.includes?(username)
          #   puts "will return true... #{username} can access #{@name} form group #{groupname} valid groups are #{@groups}"
          return true
        end
      end

      return false
    end

    def self.new_empty
      self.from_json("{}")
    end

    def type
      @type
    end

    def srcpath
      File.join(@path, @srcdir)
    end

    private def aclpath
      File.join(srcpath, "acl.toml")
    end

    private def read_acl_file
      # zerofiy aclusers
      @aclusers = [] of String
      if File.exists?(aclpath)
        @@config = TOML.parse_file(aclpath)
        #   p @@config
        @@config.try do |okconfig|
          Logger.info { "read config #{okconfig}" }
          if okconfig.has_key?("acl")
            aclhash = okconfig["acl"].as(Hash)
            aclhash["users"].as(Array).each do |u|
              threebotuser = u.as(String)
              unless threebotuser.ends_with?(".3bot")
                threebotuser += ".3bot"
                @aclusers << threebotuser
              end
            end
          end
        end
      end
    end

    def prepare_on_fs
      repo = self.repo
      templatesdir = File.join(@path, @srcdir, "templates")
      if Dir.exists?(@path)
        @jinja_env.loader = Crinja::Loader::FileSystemLoader.new(templatesdir)
      end
      read_acl_file
    end

    def repo
      if @url != ""
        gitrepo_factory = CrystalTools::GITRepoFactory.new(environment: @environment)
        gitrepo_factory.interactive = false
        repo = gitrepo_factory.get(url: @url, path: @path, branch: @branch, branchswitch: @branchswitch, depth: 1)
        if ENV.fetch("GIT_UPDATE", "0") == "1"
          repo.pull
        else
          repo.ensure
        end
        @path = repo.path
        repo
      end
    end
  end

  class Wiki < Site
    property type = "wiki"

    private def prepare_index
      if self.repo.nil?
        url_as_https = ""
      else
        url_as_https = self.repo.not_nil!.url_as_https
      end

      title = @title.size > 0 ? @title : @name
      html = render "src/tfwebserver/views/docsify.ecr"
      destindex = File.join(@path, @srcdir, "index.html")
      unless File.exists?(destindex)
        File.write(destindex, html)
      end
    end

    def prepare_docs
      # TODO: handle the url if path is empty
      @mdocs = MarkdownDocs.new(File.join(self.path, self.srcdir))
      begin
        @mdocs.checks_dups_and_fix
      rescue exception
        Logger.error(exception: exception) { "error happened #{exception}" }
      end
    end

    def prepare_on_fs
      super
      prepare_index
      prepare_docs
    end
  end

  class Website < Site
    property type = "www"
  end

  class Blog < Site
    property type = "blog"

    def blog
      Blogging::Loader.new(self).blog
    end
  end

  class Data < Site
    property type = "data"
  end

  class SiteCollection(T)
    # TODO: create collections here, with every collection have its way of loading/preparing stuff
    # custom processors and the way of serving files/documents
  end
end
