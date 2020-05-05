require "kemal"
require "toml"
require "colorize"
require "uri"
require "yaml"

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
require "./tfwebserver/*"
require "./gittools/*"

TFWeb::CLI.main
