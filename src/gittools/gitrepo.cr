require "file_utils"

module TFWeb
  HTTP_REPO_URL = /(https:\/\/)?(?P<provider>.+)(?P<suffix>\..+)\/(?P<account>.+)\/(?P<repo>.+)/
  SSH_REPO_URL  = /git@(?P<provider>.+)(?P<suffix>\..+)\:(?P<account>.+)\/(?P<repo>.+).git/

  # represents 1 specific repo on git, http & ssh can be used for updating the info
  # have nice enduser friendly operational message when it doesn't work
  class GITRepo
    property name : String
    property path : String
    property url : String
    property autocommit = false
    property branch = "master"
    property branchswitch = false
    property account = ""
    property provider = "github.com"

    def initialize(@name = "", @path = "", @url = "", @branch = "master", @branchswitch = false)
      # TODO: check if ssh-agent loaded, if yes use git notation, otherwise html
      #   @url = "" # TODO: fill in the right url (git or http), if http no authentication
      if @path == "" && @url == ""
        raise Exception.new("path and url are empty #{name}")
      end
      if @path != "" && !@url
        @url = try_read_url_from_path
      end
      if @url != ""
        if !@url.includes?("@") && !@url.starts_with?("https://")
          @url = "https://#{@url}"
        end
        infer_provider_account_repo
      end
    end

    def try_read_url_from_path
      res = `cd #{@path} && git config --get remote.origin.url`
      if $?.success?
        res.chomp
      else
        ""
      end
    end

    def make_ssh_url
      "git@#{@provider}:#{@account}/#{@name}"
    end

    def guess_repo_dir
      @path = Path["~/code/#{@provider}/#{@account}/#{name}"].expand(home: true).to_s
    end

    def ensure_repo_dir
      d = guess_repo_dir
      Dir.mkdir_p(d)
      d
    end

    def ensure_account_dir
      d = Path["~/code/#{@provider}/#{@account}"].expand(home: true)
      Dir.mkdir_p(d)
      d
    end

    def rewrite_http_to_ssh_url
      rewritten_url = @url # let's assume ssh is the default.
      infer_provider_account_repo
      make_ssh_url(@provider, @account, @reponame)
    end

    private def infer_provider_account_repo
      account_dir = ""
      rewritten_url = @url # let's assume ssh is the default.
      if @url.starts_with?("http")
        m = HTTP_REPO_URL.match(@url)
        m.try do |validm|
          @provider = validm.not_nil!["provider"].to_s
          @account = validm.not_nil!["account"].to_s
          @name = validm.not_nil!["repo"].to_s
          account_dir = ensure_account_dir
          @path = File.join(account_dir, @name)
        end
      else
        if @url.starts_with?("git@")
          m = SSH_REPO_URL.match(@url)
          m.try do |validm|
            @provider = validm.not_nil!["provider"].to_s
            @account = validm.not_nil!["account"].to_s
            @name = validm.not_nil!["repo"].to_s
            account_dir = ensure_account_dir
            @path = File.join(account_dir, name)
          end
        end
      end
    end

    def ensure_repo(pull = false)
      account_dir = ensure_account_dir
      rewritten_url = @url
      unless Dir.exists?(@path)
        `cd #{account_dir} && git clone #{rewritten_url} && git fetch`
      end
      if pull
        `cd #{guess_repo_dir} && git pull`
      end
      if @branch && @branchswitch
        `cd #{guess_repo_dir} && git checkout #{@branch}`
      end

      File.join(account_dir, @name)
    end

    # pull if needed, update if the directory is already there & .git found
    # clone if directory is not there
    # if there is data in there, ask to commit, ask message if @autocommit is on
    # if branchname specified, check branchname is the same, if not and @branchswitch is True switch branch, otherwise error
    def pull(force = false)
      repo_path = ensure_repo # handles the cloning, existence and the correct branch already.
      if force
        `cd #{repo_path} && git clean -xfd && git checkout . && git checkout #{branch} && git pull`
        $?.success?
      else
        `cd #{repo_path} && git pull`
        $?.success?
      end
    end

    # return the branchname from the repo on the filesystem, if it doesn't exist yet do an update
    private def branch_get
    end

    # check the local repo and compare to remote, if there is newer info remote return True, otherwise False
    def check_is_new
      raise
    end

    def has_sshagent
      `ps aux | grep -v grep | grep ssh-agent`
      $?.success?
    end

    # reset the repo, do a checkout . -F
    # check branchname
    def reset
      `cd #{@path} && git checkout . -F` # => "foo"
      $?.success?                        # => true
    end

    # delete the repo
    def delete
      FileUtils.rm_rf(@path)
    end

    # commit the new info, automatically do an add of all files
    def commit(msg : String)
      `git add -u && git commit -m #{msg}`
    end

    def push
      `git push`
    end

    # commit the info, do a pull if not conflicts do a push
    def commit_pull_push(msg : String)
    end
  end
end
