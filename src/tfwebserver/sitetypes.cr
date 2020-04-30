module TFWeb
  class Wiki
    property name = ""
    property path = ""
    property url = ""
    property branch = ""
    property branchswitch = false
    property autocommit = false
    property srcdir = "src"

    def prepare_on_fs
      repo = self.repo
    end

    def prepare_index
      repo = self.repo
      url_as_https = repo.not_nil!.url_as_https || ""
      html = render "src/tfwebserver/views/docsify.ecr"
      destindex = File.join(@path, @srcdir, "index.html")
      File.write(destindex, html)
    end

    def repo
      if @url != ""
        repo = TFWeb::GITRepo.new(url: @url, path: @path, branch: @branch, branchswitch: @branchswitch)
        @path = repo.ensure_repo
        repo
      end
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
      repo = self.repo
    end

    def repo
      if @url != ""
        repo = TFWeb::GITRepo.new(url: @url, path: @path, branch: @branch, branchswitch: @branchswitch)
        @path = repo.ensure_repo
        repo
      end
    end
  end
end
