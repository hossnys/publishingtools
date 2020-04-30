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



## sshtools

TBD