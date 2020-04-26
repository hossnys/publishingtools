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
      if @url != ""
        puts "url #{@url} and path #{path}"
        repo = TFWeb::GITRepo.new(url: @url, path: @path)
        @path = repo.ensure_repo
      end
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
      #   url gets more prio
      if @url != ""
        repo = TFWeb::GITRepo.new(url: @url, path: @path)
        @path = repo.ensure_repo
      end
    end
  end
end
