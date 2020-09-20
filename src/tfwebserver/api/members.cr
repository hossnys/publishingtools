require "./utils/affiliates/*"

module TFWeb
  module API
    module Members
      @@team = Team.new
      @@community = Community.new
      @@farmers = Farmers.new
      @@cache = Hash(String, String).new

      def self.cache_until_updated(affiliate, cache_key, proc)
        name = affiliate.datasite_name
        datasite = Config.datasites[name]

        to_collect = false
        if !@@cache.has_key?(cache_key)
          to_collect = true
          Logger.debug { "cannot find #{name} data in cache (pulled at #{datasite.pulled_at}), collecting..." }
        elsif affiliate.collected_at < datasite.pulled_at
          Logger.debug { "outdated #{name} data in cache, (collected at #{affiliate.collected_at}, pulled at #{datasite.pulled_at}), collecting..." }
          to_collect = true
        end

        if to_collect
          data = proc.call
          @@cache[cache_key] = data
          data
        else
          Logger.debug { "found #{name} data in cache (collected at #{affiliate.collected_at})..." }
          @@cache[cache_key]
        end
      end

      post "/api/members/list" do |env|
        projects_json = env.params.json.fetch("projects", %([])).to_s
        contribution_types_json = env.params.json.fetch("contribution_types", %([])).to_s
        projects = Array(Int32).from_json(projects_json)
        contribution_types = Array(Int32).from_json(contribution_types_json)
        env.response.content_type = "application/json"

        cache_key = "#{@@team.datasite_name}_#{projects}_#{contribution_types}"
        cache_until_updated(@@team, cache_key, ->{ @@team.list_members(projects, contribution_types) })
      end

      post "/api/partners/list" do |env|
        env.response.content_type = "application/json"

        cache_until_updated(@@community, @@community.datasite_name, ->@@community.list_partners)
      end

      post "/api/farmers/list" do |env|
        env.response.content_type = "application/json"
        cache_until_updated(@@farmers, @@farmers.datasite_name, ->@@farmers.list_farmers)
      end
    end
  end
end
