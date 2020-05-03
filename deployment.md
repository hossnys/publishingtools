# document for operations team

- 3 digital ocean machines (one of them will host code and caddy and create tunnels to the other two machines)
- fill configurations of two in sshconnections.toml described in the repository README.md
- remember to add ports 80, 443 in the configuration
- in the 3rd machine run the sshtool on that sshconections.toml
- configure websites and wikis you want to serve as defined in `websitesandwikis.toml` file
- run the server `shards build --error-trace && ./bin/tfweb -c websitesandwikis.toml`