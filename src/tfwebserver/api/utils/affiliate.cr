require "toml"
require "json"
require "crystaltools"
require "./cons"

module TFWeb
  class Affiliate
    @path = ""
    property datasite_name = ""
    property collected_at = Time.unix(0)

    def get_repo
      # get repo from datasites config or directly from a factory
      unless Config.datasites.has_key?(@datasite_name)
        raise "could not find a configured data site for #{@datasite_name}"
      end

      Config.datasites[@datasite_name].repo.not_nil!
    end

    def path
      repo = get_repo
      if (value = @path) == ""
        @path = File.join(repo.path, @datasite_name)
      else
        value
      end
    end

    def collect_data(start_with)
      affiliates_data = [] of Hash(String, TOML::Type)
      Dir.each_child(path) do |affiliate|
        affiliate_path = File.join(path, affiliate).to_s
        if Dir.exists?(affiliate_path)
          toml_path = ""
          avatar = ""
          Dir.each_child(affiliate_path) do |affiliate_file|
            file_path = File.join(affiliate_path, affiliate_file).to_s
            ext = File.extname(affiliate_file)
            if affiliate_file.starts_with?(start_with) && ext == ".toml"
              toml_path = file_path
            elsif IMG_EXT.includes?(ext)
              avatar = File.join(affiliate, affiliate_file)
            end
          end
          affiliate_data = TOML.parse_file(toml_path)
          affiliate_data["avatar"] = avatar
          affiliates_data << affiliate_data
        end
      end

      @collected_at = Time.utc
      affiliates_data
    end
  end
end
