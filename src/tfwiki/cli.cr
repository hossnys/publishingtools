# file: help.cr
require "option_parser"

OptionParser.parse do |parser|
  parser.banner = "Welcome to The Beatles App!"

  parser.on "-v", "--version", "Show version" do
    puts "version 1.0"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

# this section must exist in book.toml for any wiki/book
# [preprocessor.tfwiki]
# # The command can also be specified manually
# command = "tfwiki -p"
# # Only run the `foo` preprocessor for the HTML and EPUB renderer
# renderer = ["html", "epub"]
