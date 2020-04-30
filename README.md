# Publishing tools
Publishing tools consist of multiple things a wiki and static websites server, ssh tunneling tools used for deployments mainly.

## tfweb

`tfweb` is a wiki server/static websites server mainly built to drive the websites infrastructure for [threefold.io](https://threefold.io)

### Configurations

tfweb config is toml based, to provide more expressive configurations languages and less confusing switches/command line options.


#### Server config section 
```toml
[server]
port = 3000
addr = "0.0.0.0"
```
Sets the binding `address` to `0.0.0.0` and the `port` to `3000`

#### Wiki config section

tfweb allows serving multiple wikis, with unique names. by specifying the `url` "the most common case" or the `path` on the filesystem, and the wiki source directory `srcdir`

- `url` can be ssh url or https url
- `path` is the path of the top level root of the repository on the filesystem
- `srcdir` is where the wiki dir starts in the repository
- `branch` you can specify the branch to use
- `branchswitch` forces switching to `branch` if the one on the filesystem is different.

```toml
[[wiki]]
#unique name for the wiki
name = "sdk"
#http or git url
url = "github.com/threefoldfoundation/info_tfgridsdk"
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
```

#### Website config section

```toml
#website
[[www]]
name = "freetft"
#http or git url
url = "git@github.com:threefoldfoundation/www_getfreetft.git"
#if empty will be auto created
path = ""
#commit automatically when there is new info, only works when ssh used
autocommit = false
#branch name, of "" then will be the default or what is found on the FS
branch = "development"
#switch branch automatically if the name given above and its different on FS
branchswitch = true
#path in the repo where the info is, std "src"
srcdir = ""
```
the same as wiki, but in `[[www]]` array instead, used to serve static websites 



#### Example configurations


```toml
[server]
port = 3000
addr = "0.0.0.0"

[[wiki]]
#unique name for the wiki
name = "sdk"
#http or git url
url = "github.com/threefoldfoundation/info_tfgridsdk"
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

[[wiki]]
#unique name for the wiki
name = "wiki"
#http or git url
url = "https://github.com/threefoldfoundation/info_threefold"
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

```

### Building

building is as simple as `shards build` or `shards build --error-trace` to allow more error traces information

### Running

After building you will find the binary in `bin` directory and to run `./bin/tfweb -c CONFIG_PATH.toml`



## sshtool

`sshtool` allows you to expose a service running on a machine over other networks using ssh tunneling to be exposed over other machines.


### sshtool config

`sshtool` is toml driven, where each section is an element of array `[[sshconnections]]`
note: we are planning to have full compatibility with [tcprouter](https://gihtub.com/threefoldtech/tcprouter) too.

#### Single connection config

```toml
name = "host2_https"
ipaddr = "134.122.109.244"
# port for ssh connection
port = 22
# local port on our machine, where the server runs
localport = 443
# remote port
remoteport = 443
# user
user = "root"
tcprouter_secret = ""
```
- name: connection name
- ipaddr: machine address
- port: ssh port
- localport: local port on the machine where the server runs.
- remote port: remote port

typical use cases is `443 -> 443` for the case of https and `80 -> 80` for http



#### Example of production config

```toml
[[sshconnections]]
name = "host2_https"
ipaddr = "134.122.109.244"
# port for ssh connection
port = 22
# local port on our machine, where the server runs
localport = 443
# remote port
remoteport = 443
# user
user = "root"
tcprouter_secret = ""

[[sshconnections]]
name = "host3_https"
ipaddr = "104.248.250.78"
# port for ssh connection
port = 22
# local port on our machine, where the server runs
localport = 443
# remote port
remoteport = 443
# user
user = "root"
tcprouter_secret = ""

[[sshconnections]]
name = "host2_http"
ipaddr = "134.122.109.244"
# port for ssh connection
port = 22
# local port on our machine, where the server runs
localport = 80
# remote port
remoteport = 80
# user
user = "root"
tcprouter_secret = ""

[[sshconnections]]
name = "host3_http"
ipaddr = "104.248.250.78"
# port for ssh connection
port = 22
# local port on our machine, where the server runs
localport = 80
# remote port
remoteport = 80
# user
user = "root"
tcprouter_secret = ""

```

## Caddy Deployment


Create a config `Caddyfile` and fill in your websites.
```
http://sdk.threefold.io, https://sdk.threefold.io {
       redir {
           if {scheme} is http
           / https://{host}{uri}
        } 
        tls info@threefold.io
        proxy / localhost:3000/sdk
}

http://sdk3.threefold.io, https://sdk3.threefold.io {
       redir {
           if {scheme} is http
           / https://{host}{uri}
        } 
        tls info@threefold.io
        proxy / localhost:3000/sdk
}


http://wiki.threefold.io, https://wiki.threefold.io {
       redir {
           if {scheme} is http
           / https://{host}{uri}
        } 
        tls info@threefold.io
        proxy / localhost:3000/wiki
}


http://wiki3.threefold.io, https://wiki3.threefold.io {
       redir {
           if {scheme} is http
           / https://{host}{uri}
        } 
        tls info@threefold.io
        proxy / localhost:3000/wiki
}
```
to run execute `caddy` in the same directory of the `Caddyfile`

NOTE: Make sure that you have 80, 443 connections configured on the sshtool config file to be able to do http, https.