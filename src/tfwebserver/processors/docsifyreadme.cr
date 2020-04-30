require "file_utils"
require "colorize"

module TFWeb
  class DocsifyReadmeFixerProcessor < Processor
    def match(file_name)
      return file_name == "_sidebar.md"
    end

    def process(path_obj, child)
      #   puts "checking for #{path_obj.join("README.md")}"
      newname = path_obj.join("README.md").to_s
      unless File.exists?(path_obj.join("README.md"))
        FileUtils.cp(path_obj.join(child).to_s, newname)
        puts "[docsifyreadme]created readme.md from _sidebar.md".colorize(:blue)
      end
      newname
    end
  end
end
