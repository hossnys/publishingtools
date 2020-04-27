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
      # url gets more prio
      repo = self.repo
    end

    def prepare_index
      destindex = File.join(@path, @srcdir, "index.html")
      # unless File.exists(destindex)
      idx = TFWeb.get_index_for(@name)
      File.write(destindex, idx)
    end

    def repo
      if @url != ""
        puts "url #{@url} and path #{path}"
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
      # url gets more prio
      repo = self.repo
    end

    def repo
      if @url != ""
        puts "url #{@url} and path #{path}"
        repo = TFWeb::GITRepo.new(url: @url, path: @path, branch: @branch, branchswitch: @branchswitch)
        @path = repo.ensure_repo
        repo
      end
    end
  end
end
