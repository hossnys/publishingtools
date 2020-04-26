set +ex
crystal docs --output=./docs/tfwiki
shards build
cp bin/tfwiki /usr/local/bin
mkdir -p ~/Downloads/
cp bin/tfwiki ~/Downloads/tfwiki

