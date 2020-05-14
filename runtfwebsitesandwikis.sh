set +ex
shards build --error-trace && ./bin/tfweb -c deployment/threefoldwebsitesandwikis.toml
