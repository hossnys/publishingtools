set +ex
shards build --error-trace && ./bin/tfweb -c config/websitesandwikis.toml

