# file: help.cr
require "option_parser"

module TfWiki
  module CLI
    def self.process_book
      input = STDIN.gets_to_end
      if input.empty?
        return
      end

      File.write("tmp.json", input)

      preprocessor = MdBook::Preprocessor.new(input)
      preprocessor.process
      preprocessor.to_json(STDOUT)
    end

    def self.main
      server = false
      docspath = ""
      fix = false

      OptionParser.parse! do |parser|
        parser.banner = "Usage: tfwiki [arguments]"
        parser.on("-d WIKIPATH", "--dir=WIKIPATH", "Wiki dir root") { |wikipath| docspath = wikipath }
        parser.on("-f", "--fix", "fix a dir") { fix = true }
        parser.on("-s", "--server", "starts server") { server = true }
        parser.on("-h", "--help", "Show this help") { puts parser }
      end

      if docspath != ""
        if server
          w = Walker.new
          w.check_dups(docspath)
          w.fixer(docspath)
          # puts "errors #{w.errors}"
          w.errors_as_md(docspath)
          WikiServer.setup(docspath, w)
          WikiServer.serve
        elsif fix
          w = Walker.new
          w.check_dups(docspath)
          w.fixer(docspath)
          # puts "errors #{w.errors}"
          w.errors_as_md(docspath)
        end
      end
    end
  end
end
