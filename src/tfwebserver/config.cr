module TFWeb
  module Config
    @@config : TOML::Table?

    @@wikis = Hash(String, Wiki).new
    @@websites = Hash(String, Website).new
    @@datasites = Hash(String, Data).new
    @@blogs = Hash(String, Blog).new

    GROUPS = Hash(String, ACLGroup).new

    @@include_processor = IncludeProcessor.new
    @@link_expander = LinkExpander.new

    class ACLGroup
      property name = ""
      property description = ""
      property users = Set(String).new

      def save
        GROUPS[@name] = self
      end
    end

    class Session
      property dir_path : String = Path["~/tfweb/session_data"].expand(home: true).to_s
      property secret_file_path : String = Path["~/tfweb/session_secret"].expand(home: true).to_s
      property timeout : Time::Span = 7.days

      def secret
        secret_data = ENV.fetch("SESSION_SECRET", "")

        if File.exists?(@secret_file_path)
          secret_data = File.read(@secret_file_path)
        elsif secret_data.empty?
          secret_data = Random::Secure.hex(64)
          File.write(secret_file_path, secret_data)
        end

        secret_data
      end

      def path
        unless File.exists?(@dir_path)
          FileUtils.mkdir_p(@dir_path)
        end

        @dir_path
      end
    end

    def self.load_from_file(path)
      @@config = TOML.parse_file(path)
      # p @@config
      @@config.try do |okconfig|
        okconfig.has_key?("group") && okconfig["group"].as(Array).each do |groupel|
          group = groupel.as(Hash)
          aclgroup = ACLGroup.new
          aclgroup.name = group["name"].as(String)
          aclgroup.description = group.fetch("description", "").as(String)
          # TODO: can be better?
          group["users"].as(Array).each do |u|
            threebotuser = u.as(String)
            unless threebotuser.ends_with?(".3bot")
              threebotuser += ".3bot"
            end
            aclgroup.users << threebotuser
          end
          aclgroup.save
        end

        okconfig.has_key?("wiki") && okconfig["wiki"].as(Array).each do |wikiel|
          wiki = Wiki.from_json(wikiel.as(Hash).to_json)
          @@wikis[wiki.name] = wiki
        end

        okconfig.has_key?("www") && okconfig["www"].as(Array).each do |websiteel|
          website = Website.from_json(websiteel.as(Hash).to_json)
          @@websites[website.name] = website
        end

        okconfig.has_key?("data") && okconfig["data"].as(Array).each do |datael|
          datasite = Data.from_json(datael.as(Hash).to_json)
          @@datasites[datasite.name] = datasite
        end

        okconfig.has_key?("blog") && okconfig["blog"].as(Array).each do |blogel|
          blog = Blog.from_json(blogel.as(Hash).to_json)
          @@blogs[blog.name] = blog
        end
      end
    end

    def self.server_config
      serverconfig = @@config.not_nil!["server"].as(Hash)
      {
        "port" => serverconfig["port"].as(Int64),
        "addr" => serverconfig["addr"].as(String),
      }
    end

    def self.wikis
      @@wikis
    end

    def self.websites
      @@websites
    end

    def self.datasites
      @@datasites
    end

    def self.blogs
      @@blogs
    end

    def self.include_processor
      @@include_processor
    end

    def self.link_expander
      @@link_expander
    end

    def self.all
      wikis.values + websites.values + datasites.values + blogs.values
    end
  end
end
