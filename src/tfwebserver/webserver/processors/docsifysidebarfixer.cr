require "file_utils"

module TFWeb
  class DocsifySidebarFixerProcessor # < Processor
    def match(file_name)
      return file_name.downcase == "summary.md"
    end

    def process(path_obj, child)
      unless File.exists?(path_obj.join("_sidebar.md"))
        puts "[docsifysidebar]created _sidebar.md from summary.md"

        FileUtils.cp(path_obj.join(child).to_s, path_obj.join("_sidebar.md").to_s)
      end
    end
  end
end
