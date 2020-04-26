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

require "./tfwiki/webserver/*"
require "./tfwiki/cli"
require "./gittools/*"

TfWiki::CLI.main
