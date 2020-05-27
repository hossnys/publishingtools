require "file_utils"
require "colorize"

module TFWeb
  class DocsifySidebarFixerProcessor < Processor
    def match(path)
      return path.basename.downcase == "summary.md"
    end

    def process(path)
      newname = Path.new(path.dirname, "_sidebar.md").to_s
      unless File.exists?(newname)
        puts "[docsifysidebar]created _sidebar.md from summary.md".colorize(:blue)

        FileUtils.cp(path.to_s, newname)
      end
      newname
    end
  end
end
