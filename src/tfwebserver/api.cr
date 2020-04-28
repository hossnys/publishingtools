require "kemal"
require "json"

module TFWeb
  module WebServer
    post "/api/members/list" do |env|
      projects_json = env.params.json.fetch("projects", %([])).to_s
      contribution_types_json = env.params.json.fetch("contribution_types", %([])).to_s
      projects = Array(Int32).from_json(projects_json)
      contribution_types = Array(Int32).from_json(contribution_types_json)
      env.response.content_type = "application/json"
      @@team.list_members(projects, contribution_types)
    end
    post "/api/partners/list" do |env|
      env.response.content_type = "application/json"
      @@community.list_partners
    end
    post "/api/farmers/list" do |env|
      env.response.content_type = "application/json"
      @@farmers.list_farmers
    end
  end
end
