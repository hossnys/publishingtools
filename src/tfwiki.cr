module TfWiki
  VERSION = "0.1.0"
end

# require all here
require "./tfwiki/fs/*"
require "./tfwiki/mdbook/*"
require "./tfwiki/cli"

TfWiki::CLI.main
