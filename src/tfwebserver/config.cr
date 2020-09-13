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

    class DuplicateSiteError < Exception
    end

    HTTP_REPO_URL = /((http|https):\/\/)?(?P<provider>.+)(?P<suffix>\..+)\/(?P<account>.+)\/(?P<repo>.+)/
    SSH_REPO_URL  = /(ssh:\/\/)?(git@)(?P<provider>.+)(?P<suffix>\..+)\:(?P<account>.+)\/(?P<repo>.+)(?:.git)?/

    def self.normalize_repo_url(url)
      url = url.strip
      match = HTTP_REPO_URL.match(url)
      if match.nil?
        match = SSH_REPO_URL.match(url)
      end

      if match.nil?
        return url
      end

      data = match.to_h
      provider = data["provider"]
      suffix = data["suffix"]
      account = data["account"]
      repo = data["repo"]
      "#{provider}.#{suffix}/#{account}/#{repo}"
    end

    def self.load_sites_of_type(config, config_key, site_type, collection, prev_sites)
      unless config.has_key?(config_key)
        return
      end

      config[config_key].as(Array).each do |site_config|
        site = site_type.from_json(site_config.as(Hash).to_json)

        # check duplicates
        unless site.url.strip.empty?
          normalized_url = normalize_repo_url(site.url)
          if prev_sites.has_key?(normalized_url)
            prev_site = prev_sites[normalized_url]
            if prev_site.environment == site.environment
              raise DuplicateSiteError.new(
                "duplicate repository in the same environment between #{prev_site.type}:#{prev_site.name} and #{site.type}:#{site.name}"
              )
            end
          else
            prev_sites[normalized_url] = site
          end
        end

        collection[site.name] = site
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
            threebotuser = u.as(String).downcase
            unless threebotuser.ends_with?(".3bot")
              threebotuser += ".3bot"
            end
            aclgroup.users << threebotuser
          end
          aclgroup.save
        end

        # for duplication check
        prev_sites = Hash(String, Site).new

        begin
          load_sites_of_type(okconfig, "wiki", Wiki, @@wikis, prev_sites)
          load_sites_of_type(okconfig, "www", Website, @@websites, prev_sites)
          load_sites_of_type(okconfig, "data", Data, @@datasites, prev_sites)
          load_sites_of_type(okconfig, "blog", Blog, @@blogs, prev_sites)
        rescue exception : DuplicateSiteError
          Logger.error { exception.message }
          Logger.error { "Plese fix the config and try again, aborting..." }
          exit(1)
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
