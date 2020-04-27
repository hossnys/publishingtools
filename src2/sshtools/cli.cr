# file: help.cr
require "option_parser"
# require "toml"

module SSHTools
  module CLI
    def self.main
      theconfigpath = ""
      OptionParser.parse! do |parser|
        parser.banner = "Usage: sshtools [arguments]"
        parser.on("-c CONFIGPATH", "--config=CONFIGPATH", "TOML config file") { |configpath| theconfigpath = configpath }
        parser.on("-h", "--help", "Show this help") { puts parser }
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
