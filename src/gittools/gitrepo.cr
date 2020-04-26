
module GITTools

  #represents 1 specific repo on git, http & ssh can be used for updating the info
  #have nice enduser friendly operational message when it doesn't work
  class GITRepo
    @name = String
    @path = String
    @url = String
    @autocommit = Bool    
    @branch = String
    @branchswitch = Bool

    def initialize(@name : String, path : String = "",  url : String = "",@autocommit : Bool =False,
        @autocommit : Bool =False, branch : String = "",@branchswitch : Bool =False )

      #TODO: check if ssh-agent loaded, if yes use git notation, otherwise html
      @url = "" #TODO: fill in the right url (git or http), if http no authentication

      if path == ''
        @path = "#{HOME}/code/#{ACCOUNTNAME}/#{REPONAME}"  #TODO
      else
        @path = path
      end

    end

    # pull if needed, update if the directory is already there & .git found
    # clone if directory is not there
    # if there is data in there, ask to commit, ask message if @autocommit is on
    # if branchname specified, check branchname is the same, if not and @branchswitch is True switch branch, otherwise error
    def update
    end

    #return the branchname from the repo on the filesystem, if it doesn't exist yet do an update
    private def branch_get

    end

    #check the local repo and compare to remote, if there is newer info remote return True, otherwise False
    def check_is_new

    end

    #reset the repo, do a checkout . -F
    #check branchname
    def reset
    
    end

    #delete the repo
    def delete

    end

    #commit the new info, automatically do an add of all files
    def commit (msg : String)

    end 

    def push
    end
    
    #commit the info, do a pull if not conflicts do a push
    def commit_pull_push (msg : String)
    end


  end 
end
