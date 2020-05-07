require "file_utils"
require "colorize"

module TFWeb
  class DocsifyReadmeFixerProcessor < Processor
    def match(path)
      return path.basename == "_sidebar.md"
    end

    def process(path)
      #   puts "checking for #{path_obj.join("README.md")}"
      newname = Path.new(path.dirname, "README.md").to_s
      unless File.exists?(newname)
        FileUtils.cp(path.to_s, newname)
        puts "[docsifyreadme]created readme.md from _sidebar.md".colorize(:blue)
      end
      newname
    end
  end
end
