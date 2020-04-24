module TfWiki
  VERSION = "0.1.0"

  class FInfoTracker
    property count = 0
    property paths = [""]

    def to_s
      "FInfoTracker #{count} "
    end
  end
end

# require all here
require "./tfwiki/fs/*"
require "./tfwiki/mdbook/*"
require "./tfwiki/wikiserver/*"
require "./tfwiki/cli"

TfWiki::CLI.main
