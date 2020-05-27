require "crinja"

module TFWeb
  GROUPS = Hash(String, ACLGroup).new

  class ACLGroup
    property name = ""
    property description = ""
    property users = Set(String).new

    def save
      GROUPS[@name] = self
    end
  end

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

    @[JSON::Field(emit_null: true)]
    property domain = ""

    @[JSON::Field(ignore: true)]
    property jinja_env = Crinja.new

    def to_s
      "#{@name} #{@auth} #{@environment} "
    end

    def user_can_access?(username)
      return true if @auth == false
      return true if @groups.size == 0 && @aclusers.size == 0 # if there's no acl.toml too it's public.
      return true if @aclusers.includes?(username)
      groups.each do |groupname|
        if GROUPS[groupname].users.includes?(username) ||
           #   puts "will return true... #{username} can access #{@name} form group #{groupname} valid groups are #{@groups}"
           return true
        end
      end

      return false
    end

    def self.new_empty
      self.from_json("{}")
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
          puts "read config #{okconfig}"
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
        repo = TFWeb::GITRepo.new(url: @url, path: @path, branch: @branch, branchswitch: @branchswitch, environment: @environment)
        @path = repo.ensure_repo
        repo
      end
    end
  end

  class Wiki < Site
    private def prepare_index
      repo = self.repo
      title = @title.size > 0 ? @title : @name
      url_as_https = repo.not_nil!.url_as_https || ""
      html = render "src/tfwebserver/views/docsify.ecr"
      destindex = File.join(@path, @srcdir, "index.html")
      unless File.exists?(destindex)
        File.write(destindex, html)
      end
    end

    def prepare_on_fs
      super
      prepare_index
    end
  end

  class Website < Site
  end

  class Blog < Site
    def blog
      Blogging::Loader.new(self).blog
    end
  end

  class Data < Site
  end

  class SiteCollection(T)
    # TODO: create collections here, with every collection have its way of loading/preparing stuff
    # custom processors and the way of serving files/documents
  end
end
