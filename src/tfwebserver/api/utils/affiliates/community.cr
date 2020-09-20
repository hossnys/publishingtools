require "json"
require "../affiliate"

module TFWeb
  class Partner
    include JSON::Serializable
    property name : String
    property description : String
    property stars : Int32
    property url : String
    property logo : String
    @[JSON::Field(key: "sectionID")]
    property section_id : Int32
    property rank : Int32

    def initialize(@name, @description, @stars, @url, @logo, @section_id, @rank)
    end
  end

  class Community < Affiliate
    @datasite_name = "partners"

    def list_partners
      partners_data = collect_data("info")
      partners = [] of Partner
      partners_data.each do |partner_data|
        name = partner_data.fetch("name", "").as(String)
        description = partner_data.fetch("description", "").as(String)
        url = partner_data.fetch("url", "").as(String)
        logo = partner_data.fetch("avatar", "").as(String)

        begin
          stars = partner_data.fetch("stars", 0).as(Int64).to_i
        rescue exception
          stars = partner_data.fetch("stars", "0").as(String).to_i
        end

        begin
          rank = partner_data.fetch("rank", 0).as(Int64).to_i
        rescue exception
          rank = partner_data.fetch("rank", "0").as(String).to_i
        end

        begin
          section_id = partner_data.fetch("sectionID", 0).as(Int64).to_i
        rescue exception
          section_id = partner_data.fetch("sectionID", "0").as(String).to_i
        end

        partner = Partner.new(name, description, stars, url, logo, section_id, rank)
        partners << partner
      end
      partners.to_json
    end
  end
end
