require "json"
require "../affiliate"

module TFWeb
  class Farmer
    include JSON::Serializable
    property name : String
    property description : String
    property type : String
    property contact : String
    property url : String
    property logo : String

    def initialize(name, description, type, contact, url, logo)
      @name = name
      @description = description
      @type = type
      @contact = contact
      @url = url
      @logo = logo
    end
  end

  class Farmers < Affiliate
    @repo_key = "farmers"

    def list_farmers
      farmers_data = collect_data("info")
      farmers = [] of Farmer
      farmers_data.each do |farmer_data|
        name = farmer_data.fetch("name", "").as(String)
        description = farmer_data.fetch("description", "").as(String)
        type = farmer_data.fetch("type", "").as(String)
        contact = farmer_data.fetch("contact", "").as(String)
        url = farmer_data.fetch("url", "").as(String)
        logo = farmer_data.fetch("avatar", "").as(String)

        farmer = Farmer.new(name, description, type, contact, url, logo)
        farmers << farmer
      end
      farmers.to_json
    end
  end
end
