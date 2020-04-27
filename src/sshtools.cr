module SSHTools
  VERSION = "0.1.0"
  
require "./sshtools/cli"
require "./sshtools/*"

SSHTools::CLI.main
