# document for operations team

- 3 digital ocean machines (one of them will host code and caddy and create tunnels to the other two machines)
- install caddy
- fill configurations of two in sshconnections.toml described in the repository README.md
- remember to add ports 80, 443 in the configuration
- in the 3rd machine run the sshtool on that sshconections.toml
- configure websites and wikis you want to serve as defined in `deployment/threefoldwebsitesandwikis.toml` file
- run the server `shards build --error-trace && ./bin/tfweb -c deployment/threefoldwebsitesandwikis.toml`
- for Caddyfile make sure to change the basicauth used to the suitable ones agreed on in the ops team.

## troubleshooting

### can't build 

https://github.com/threebotserver/publishingtools/issues/75

if for any reason you couldn't build remotely, make sure to do `shards build --static` on your local machine and then scp it over `scp bin/tfweb root@134.209.203.153:/usr/bin/tfweb` and use that binary instead

### errors when starting server regarding cloning

there's that section
```
[[wiki]]
#unique name for the wiki
name = "ambassadors"
#http or git url
url = "git@github.com:threefoldfoundation/info_ambassadors.git"
#if empty will be auto created
path = ""
#commit automatically when there is new info, only works when ssh used
autocommit = false
#branch name, of "" then will be the default or what is found on the FS
branch = "development"
#switch branch automatically if the name given above and its different on FS
branchswitch = false
#path in the repo where the info is, std "src"
srcdir = "src"
#environment name (for example:  production, staging, test), is used to define location where code will be checked out is ~/$environment/code/... 
#if empty then is ~/sandbox/code
environment = "production"

[[wiki]]
name = "advisors"
url = "git@github.com:threefoldfoundation/info_advisors.git"
path = ""
autocommit = false
branch = "development"
branchswitch = false
srcdir = "src"
environment = "production"

[[wiki]]
name = "board"
url = "git@github.com:threefoldfoundation/info_board.git"
path = ""
autocommit = false
branch = "development"
branchswitch = false
srcdir = "src"
environment = "production"
```
and these are private repos, so make sure you have access on these repos + and forward your ssh agent using `-tA` flag when connecting to the machine.