require "option_parser"
require "toml"

module SSHTool
  module CLI
    def self.main
      path = ""
      OptionParser.parse! do |parser|
        parser.banner = "Usage: sshtool [arguments]"
        parser.on("-c=CONFIGPATH", "--config=CONFIGPATH", "TOML config file") { |configpath| path = configpath }
        parser.on("-h", "--help", "Show this help") { puts parser }
      end
      unless path == ""
        begin
          sshtool = SSHTool.new(configpath: path)
          sshtool.start
        rescue exception
          puts "couldn't start the ssh tool #{exception}"
        end
      end
    end
  end
end