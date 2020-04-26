# file: help.cr
require "option_parser"
require "toml"

module TFWeb
  module CLI
    def self.main
      theconfigpath = ""
      OptionParser.parse! do |parser|
        parser.banner = "Usage: tfwiki [arguments]"
        parser.on("-c CONFIGPATH", "--config=CONFIGPATH", "TOML config file") { |configpath| theconfigpath = configpath }
        parser.on("-h", "--help", "Show this help") { puts parser }
      end

      puts theconfigpath
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
