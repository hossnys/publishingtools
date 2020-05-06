require "kemal"
require "toml"
require "colorize"
require "uri"

module TFWeb
  VERSION = "0.1.0"

  class FInfoTracker
    property count = 0
    property paths = [] of String

    def to_s
      "FInfoTracker #{count} "
    end
  end
end

require "./tfwebserver/cli"
require "./tfwebserver/api/*"
require "./tfwebserver/*"
require "./gittools/*"

TFWeb::CLI.main
