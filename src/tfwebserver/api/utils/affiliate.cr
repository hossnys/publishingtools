require "toml"
require "json"
require "crystaltools"
require "./cons"

module TFWeb
  class Affiliate
    @path = ""
    @repo_key = ""

    def get_repo
      # get repo from datasites config or directly from a factory
      unless Config.datasites.has_key?(@repo_key)
        raise "could not find a configured data site for #{@repo_key}"
      end

      Config.datasites[@repo_key].repo.not_nil!
    end

    def path
      repo = get_repo
      if (value = @path) == ""
        @path = File.join(repo.path, @repo_key)
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
      affiliates_data
    end
  end
end
