require "toml"

module SSHTools
  class SSHConnection
    def initialize(@name : String = "", @ipaddr : String  = "", @port = "", @localport : Int = 3000, @remoteport : Int = 3000 )
      @tcprouter_secret = "" #not implemented yet
    end

    #check the server is accessible
    def ping
      #TODO: first pingtcp then ping ssh, whatever fails first returns False
    end

    private def pingtcp
      #implement ping to server
      `...`
      ! $?.success or ...
    end 

    private def pingssh
      #implement ssh test to server, is the ssh channel still open
    end     

    #create the portforward connection
    def portforward
      if @tcprouter_secret != "":
        tcprouter_client_connect
      else:
        ssh_client_connect_portforward
      end
    end

    #monitoring loop, make sure that the server responds, if not restart
    def monitor
      #TODO: use https://github.com/ysbaddaden/earl ideas (the supervisor has to be on sshtools) to run multiple instances of the SSHConnection
      # see https://github.com/ysbaddaden/earl/blob/master/samples/supervisor.cr
      while true
        sleep 5
        if ! ping
          #TODO: kill existing process, need to make sure its gone
          start
        end
      end      
    end

    def start
      if @remoteport
        portforward
      end
    end

    #will install redis & tcprouter server
    #redis will be accessible with secret as configured in config file
    def tcprouter_server_install ()
      #TODO: phase2: first check tcprouter server installed (which)
      #TODO: if not install

    end

    #will install redis & tcprouter server
    private def tcprouter_client_connect
      #TODO: phase2: check tcprouter client exists, if not complain
      #TODO: configure the tcprouter client 

    end

    #do the portforward over ssh
    private def ssh_client_connect_portforward
      #TODO: can use the ssh client from crystal itself (is connection to libssh2)
    end


  end
  class SSHTools

    private @sshconnections = Hash(String : SSHConnection)

    def initialize

    end

    def get(@configpath: String = "")

      @@config = TOML.parse_file(configfileconfigpathpath)
      #   p @@config
      @@config.try do |okconfig|
        config["connection"].as(Array).each do |connhash|
          conn = connhash.as(Hash)
          p conn
          obj = SSHConnection.new
          obj.name = wiki["name"].as(String)
          obj.ipaddr = wiki["ipaddr"].as(String)
          obj.port = wiki["port"].as(Int)
          obj.localport = wiki["localport"].as(Int)
          obj.remoteport = wiki["remoteport"].as(Int)
          @sshconnections[obj.name] = obj
        end

        p @sshconnections

    end 
         

    def get(@name : String = "", @ipaddr : String = "", @port : Int = "", @localport : Int = 3000, @remoteport : Int = 3000)
        if ! name in @sshconnections
          @sshconnections[name] = SSHConnection(name,ipaddr,port,localport,remoteport)
        @sshconnections[name]
    end

    def start

      #TODO: see above use https://github.com/ysbaddaden/earl 
      #implement supervisor, running multiple of these connections, make sure they all keep on working
      #report every 10 sec the status of the different connections

    end

end
