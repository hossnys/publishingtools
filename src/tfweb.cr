module TFWeb
  VERSION = "0.1.0"

  class FInfoTracker
    property count = 0
    property paths = [""]

    def to_s
      "FInfoTracker #{count} "
    end
  end
end

require "./tfwebserver/*"
require "./tfwebserver/cli"
require "./gittools/*"

TFWeb::CLI.main
