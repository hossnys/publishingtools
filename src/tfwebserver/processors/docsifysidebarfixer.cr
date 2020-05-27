require "file_utils"

module TFWeb
  class DocsifySidebarFixerProcessor < Processor
    def match(path)
      return path.basename.downcase == "summary.md"
    end

    def process(path)
      newname = Path.new(path.dirname, "_sidebar.md").to_s
      unless File.exists?(newname)
        Logger.info { "[docsifysidebar]created _sidebar.md from summary.md" }

        FileUtils.cp(path.to_s, newname)
      end
      newname
    end
  end
end
