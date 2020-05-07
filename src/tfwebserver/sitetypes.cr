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

    def self.new_empty
      self.from_json("{}")
    end

    def prepare_on_fs
      repo = self.repo
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
      File.write(destindex, html)
    end

    def prepare_on_fs
      super

      prepare_index
    end
  end

  class Website < Site
  end

  class Blog < Site
    property blog : Blogging::Blog?

    def prepare_on_fs
      super

      loader = Blogging::Loader.new(self)
      @blog = loader.blog
    end
  end

  class Data < Site
  end

  class SiteCollection(T)
    # TODO: create collections here, with every collection have its way of loading/preparing stuff
    # custom processors and the way of serving files/documents
  end
end
