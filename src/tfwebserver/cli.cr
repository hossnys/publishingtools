# file: help.cr
require "option_parser"
require "toml"

module TFWeb
  module CLI
    BUILD_BRANCH   = {{ `git rev-parse --abbrev-ref HEAD`.chomp.stringify }}
    BUILD_COMMIT   = {{ `git rev-parse HEAD`.chomp.stringify }}
    BUILD_LAST_TAG = {{ `git describe --abbrev=0 --tags`.chomp.stringify }}
    SHARDS_VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

    VERSION = "tfweb #{BUILD_LAST_TAG} (#{BUILD_BRANCH})##{BUILD_COMMIT})"

    def self.main
      theconfigpath = ""
      OptionParser.parse! do |parser|
        parser.banner = "Usage: tfwiki [arguments]"
        parser.on("-c CONFIGPATH", "--config=CONFIGPATH", "TOML config file") { |configpath| theconfigpath = configpath }
        parser.on("-h", "--help", "Show this help") { puts parser }
        parser.on("-v", "--version", "Version info of tfweb") { puts VERSION }
      end

      unless theconfigpath == ""
        begin
          WebServer.serve(theconfigpath)
        rescue exception
          puts "couldn't start server #{exception}"
        end
      end
    end
  end
end
