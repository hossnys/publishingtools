require "file_utils"

module TfWiki
  class DocsifyReadmeFixerProcessor # < Processor
    def match(file_name)
      return file_name == "_sidebar.md"
    end

    def process(path_obj, child)
      puts "checking for #{path_obj.join("README.md")}"
      unless File.exists?(path_obj.join("README.md"))
        FileUtils.cp(path_obj.join(child).to_s, path_obj.join("README.md").to_s)
        puts "[docsifyreadme]created readme.md from _sidebar.md"
      end
    end
  end
end
