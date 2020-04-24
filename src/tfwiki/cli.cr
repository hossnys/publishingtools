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
      if ARGV.size == 1
        w = Walker.new
        against = ARGV[0]
        w.check_dups(against)
        w.fixer(against)
        # puts "errors #{w.errors}"
        w.errors_as_md(against)
      end
    end
  end
end

# OptionParser.parse do |parser|
#   parser.banner = "Welcome to The Beatles App!"

#   parser.on "-v", "--version", "Show version" do
#     puts "version 1.0"
#     exit
#   end
#   parser.on "-h", "--help", "Show help" do
#     puts parser
#     exit
#   end
# end
# this section must exist in book.toml for any wiki/book
# [preprocessor.tfwiki]
# # The command can also be specified manually
# command = "tfwiki -p"
# # Only run the `foo` preprocessor for the HTML and EPUB renderer
# renderer = ["html", "epub"]
