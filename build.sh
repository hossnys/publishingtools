set -ex
#crystal docs --output=./docs/tfweb
shards update
shards build
cp bin/tfweb /usr/local/bin
mkdir -p ~/Downloads/
cp bin/tfweb ~/Downloads/tfwiki

