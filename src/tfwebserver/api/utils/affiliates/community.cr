require "json"
require "../affiliate"

module TFWeb
  class Partner
    include JSON::Serializable
    property name : String
    property description : String
    property stars : Int32
    property url : String
    property avatar : String

    def initialize(name, description, stars, url, avatar)
      @name = name
      @description = description
      @stars = stars
      @url = url
      @avatar = avatar
    end
  end

  class Community < Affiliate
    @path = ""
    @repo_key = "partners"

    def list_partners
      partners_data = collect_data("info")
      partners = [] of Partner
      partners_data.each do |partner_data|
        name = partner_data.fetch("name", "").as(String)
        description = partner_data.fetch("description", "").as(String)
        url = partner_data.fetch("url", "").as(String)
        avatar = partner_data.fetch("avatar", "").as(String)

        begin
          stars = partner_data.fetch("stars", 0).as(Int64).to_i
        rescue exception
          stars = partner_data.fetch("stars", "0").as(String).to_i
        end

        partner = Partner.new(name, description, stars, url, avatar)
        partners << partner
      end
      partners.to_json
    end
  end
end
