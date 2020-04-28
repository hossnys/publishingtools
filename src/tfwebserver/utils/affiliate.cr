require "../../gittools/*"
require "toml"
require "json"
require "./cons"

module TFWeb
  class Affiliate
    @path = ""
    @repo_key = ""

    def initialize
      repo = GITRepo.new(url: REPO_URLS[@repo_key])
      repo_path = repo.ensure_repo(pull = true)
      @path = File.join(repo_path, @repo_key)
    end

    def collect_data(start_with)
      affiliates_data = [] of Hash(String, TOML::Type)
      Dir.each_child(@path) do |affiliate|
        affiliate_path = File.join(@path, affiliate).to_s
        if Dir.exists?(affiliate_path)
          toml_path = ""
          avatar = ""
          Dir.each_child(affiliate_path) do |affiliate_file|
            file_path = File.join(affiliate_path, affiliate_file).to_s
            ext = File.extname(affiliate_file)
            if affiliate_file.starts_with?(start_with) && ext == ".toml"
              toml_path = file_path
            elsif IMG_EXT.includes?(ext)
              avatar = file_path
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
