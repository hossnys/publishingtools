require "toml"

module SSHTool
  class SSHConnection
    property name : String
    property ipaddr : String
    property user : String
    property localport : Int64
    property remoteport : Int64

    def initialize(
      @name,
      @ipaddr, 
      @user = "root", 
      @localport = 3000, 
      @remoteport = 3000
    )   
    end

    private def startupcmd
      "ssh -R #{@localport}:127.0.0.1:#{@remoteport} -N #{@user}@#{@ipaddr}"
    end

    def pid
      `pgrep --exact --full "#{startupcmd}"`.split()
    end

    def pingtcp
      `nc -z #{@ipaddr} #{@localport}`
      $?.success?  
    end

    def pingssh
      `nc -z #{@ipaddr} 22`
      $?.success?
    end

    def is_running
      pingtcp && pingssh
    end

    def start
      `#{startupcmd}`
    end

    def kill
      pid.each do |pid|
        `kill -9 #{pid}`
      end
    end

    def restart
      kill
      start
    end
  end


  class SSHTool
    property configpath : Path
    property connections : Hash(String, SSHConnection)

    def initialize(configpath : String)
      @configpath = Path[configpath].expand(home: true)
      @connections = {} of String => SSHConnection
      @channel = Channel(Nil).new

      config = readconfig
      config["sshconnections"].as(Array).each do |connection|
        connection = connection.as(Hash)
        name = connection["name"].as(String)
        @connections[name] = SSHConnection.new(
          name: name,
          ipaddr: connection["ipaddr"].as(String),
          user: connection["user"].as(String),
          localport: connection["localport"].as(Int64),
          remoteport: connection["remoteport"].as(Int64)
        )
      end
    end

    private def readconfig
      TOML.parse_file(@configpath)
    rescue File::NotFoundError
      puts "Configuration file not found"
      exit 1
    rescue TOML::ParseException
      puts "Invalid configuration"
      exit 1
    end

    def get(
      name, 
      ipaddr : String = "", 
      user : String = "root", 
      localport : Int64 = 3000, 
      remoteport : Int64 = 3000
    )
        unless @connections.includes? name
          @connections[name] = SSHConnection.new(name, ipaddr, user, localport, remoteport)
        end
        @connections[name]
    end

    def start
      @connections.each do |name, connection|
        puts "Connection #{name} is started"
        spawn connection.start
        spawn monitor connection
      end
      @channel.receive
    end

    def monitor(connection : SSHConnection)
      loop do
        sleep 10.seconds
        if connection.is_running
          puts "Connection #{connection.name} is ok"
        else
          puts "Connection #{connection.name} is restarted"
          connection.restart
          spawn monitor connection
        end
      end
    end

  end
end
