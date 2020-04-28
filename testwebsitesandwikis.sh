set +ex
shards build --error-trace && ./bin/tfweb -c websitesandwikis.toml

