require "../../gittools/*"
require "toml"
require "json"
require "./cons"

module TFWeb
  class Partner
    include JSON::Serializable
    property name : String
    property description : String
    property stars : Int32
    property url : String

    def initialize(name, description, stars, url)
      @name = name
      @description = description
      @stars = stars
      @url = url
    end
  end

  class Community
    @path = ""
    @repo_url = "https://github.com/threefoldfoundation/data_partners/"

    def initialize
      repo = GITRepo.new(url: @repo_url)
      repo_path = repo.ensure_repo(pull = true)
      @path = File.join(repo_path, "partners")
    end

    def list_partners
      partners = [] of Partner
      Dir.each_child(@path) do |partner|
        partner_path = File.join(@path, partner).to_s
        if Dir.exists?(partner_path)
          toml_path = ""
          avatar = ""
          Dir.each_child(partner_path) do |partner_file|
            file_path = File.join(partner_path, partner_file).to_s
            ext = File.extname(partner_file)
            if partner_file.starts_with?("info") && ext == ".toml"
              toml_path = file_path
            elsif IMG_EXT.includes?(ext)
              avatar = file_path
            end
          end
          partner_data = TOML.parse_file(toml_path)

          name = partner_data.fetch("name", "").as(String)
          description = partner_data.fetch("description", "").as(String)
          url = partner_data.fetch("url", "").as(String)

          begin
            stars = partner_data.fetch("stars", 0).as(Int64).to_i
          rescue exception
            stars = partner_data.fetch("stars", "0").as(String).to_i
          end

          partner = Partner.new(name, description, stars, url)
          partners.push(partner)
        end
      end
      return partners.to_json
    end
  end
end
