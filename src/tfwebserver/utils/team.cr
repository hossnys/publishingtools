require "../../gittools/*"
require "toml"
require "json"
require "./cons"

module TFWeb
  TEAM_REPO_URL = "https://github.com/threefoldfoundation/data_team"

  class Member
    include JSON::Serializable
    property full_name : String
    property description : String
    property why_threefold : String
    property function : String
    property linkedin : String
    property project_ids : Array(Int32)
    property contribution_ids : Array(Int32)
    property nationality : String
    property avatar : String

    def initialize(full_name, description, why_threefold, function, linkedin, project_ids, contribution_ids, nationality, avatar)
      @full_name = full_name
      @description = description
      @why_threefold = why_threefold
      @function = function
      @linkedin = linkedin
      @project_ids = project_ids
      @contribution_ids = contribution_ids
      @nationality = nationality
      @avatar = avatar
    end

    def get_projects_or_contributions(key)
      if key == "project_ids"
        return @project_ids
      else
        return @contribution_ids
      end
    end
  end

  class Team
    @path = ""

    def initialize
      repo = GITRepo.new(url: TEAM_REPO_URL)
      repo_path = repo.ensure_repo(pull = true)
      @path = File.join(repo_path, "team")
    end

    private def filter_member_mapping(member, projects, contribution_types)
      Hash.zip(projects, contribution_types).each do |project, contribution|
        project_idx = member.get_projects_or_contributions("project_ids").index(project)
        if project_idx && !member.get_projects_or_contributions("contribution_ids").empty?
          if member.get_projects_or_contributions("contribution_ids")[project_idx] == contribution
            return false
          end
        end
      end
      return true
    end

    private def filter_members(members, projects, contribution_types)
      if projects
        arr = projects
        key = "project_ids"
      else
        arr = contribution_types
        key = "contribution_ids"
      end
      arr.each do |item|
        members.reject! { |member| !member.get_projects_or_contributions(key).includes?(item) }
      end
    end

    def list_members(projects = nil, contribution_types = nil)
      projects = projects || [] of Int32
      contribution_types = contribution_types || [] of Int32
      if !projects.empty? && !contribution_types.empty? && projects.size != contribution_types.size
        raise Exception.new("size of projects needs to be same as `contribution_types` ")
      end
      members = [] of Member
      Dir.each_child(@path) do |member|
        member_path = File.join(@path, member).to_s
        if Dir.exists?(member_path)
          toml_path = ""
          avatar = ""
          Dir.each_child(member_path) do |member_file|
            file_path = File.join(member_path, member_file).to_s
            ext = File.extname(member_file)
            if member_file.starts_with?("publicinfo") && ext == ".toml"
              toml_path = file_path
            elsif IMG_EXT.includes?(ext)
              avatar = file_path
            end
          end
          member_data = TOML.parse_file(toml_path)

          project_ids = [] of Int32
          member_data.fetch("project_ids", project_ids).as(Array).each do |project_id|
            project_ids.push(project_id.as(Int64).to_i)
          end

          contribution_ids = [] of Int32
          member_data.fetch("contribution_ids", contribution_ids).as(Array).each do |contribution_id|
            contribution_ids.push(contribution_id.as(Int64).to_i)
          end

          full_name = member_data.fetch("full_name", "").as(String)
          description = member_data.fetch("description", "").as(String)
          why_threefold = member_data.fetch("why_threefold", "").as(String)
          function = member_data.fetch("function", "").as(String)
          linkedin = member_data.fetch("linkedin", "").as(String)
          nationality = member_data.fetch("nationality", "").as(String)

          member = Member.new(full_name, description, why_threefold, function, linkedin, project_ids, contribution_ids, nationality, avatar)
          members << member
        end
      end
      if projects.empty? || contribution_types.empty?
        filter_members(members, projects, contribution_types)
      else
        members.reject! { |member| filter_member_mapping(member, projects, contribution_types) }
      end
      members.to_json
    end
  end
end
