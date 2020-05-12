require "crinja"

module TFWeb
  class Site
    property name = ""
    property title = ""
    property path = ""
    property url = ""
    property branch = ""
    property branchswitch = false
    property autocommit = false
    property srcdir = "src"
    property environment = ""
    property jinja_env = Crinja.new

    # def initialize()
    #   @jinja_env = Crinja.new()
    # end

    def prepare_on_fs
      repo = self.repo
      templatesdir = File.join(@path, @srcdir, "templates")
      if Dir.exists?(@path)
        @jinja_env.loader = Crinja::Loader::FileSystemLoader.new(templatesdir)
      end
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
  end

  class Data < Site
  end

  class SiteCollection(T)
    # TODO: create collections here, with every collection have its way of loading/preparing stuff
    # custom processors and the way of serving files/documents
  end
end
