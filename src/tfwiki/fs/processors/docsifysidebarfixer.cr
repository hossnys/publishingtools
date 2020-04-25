require "file_utils"

module TfWiki
  class DocsifySidebarFixerProcessor # < Processor
    def match(file_name)
      return file_name.downcase == "summary.md"
    end

    def process(path_obj, child)
      unless File.exists?(path_obj.join("_sidebar.md"))
        FileUtils.cp(path_obj.join(child).to_s, path_obj.join("_sidebar.md").to_s)
      end
      puts "[docsifysidebar]created _sidebar.md from summary.md"
    end
  end
end
