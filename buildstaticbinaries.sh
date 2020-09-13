#!/bin/sh
## should be used in alpine container

#sudo docker run -it --name crystalalpine -h crystalalpine --privileged -v /opt/crystalalpine:/opt crystallang/crystal:0.34.0-alpine sh
## probably should add --release flag too
shards build --static --link-flags "$(pkg-config libxml-2.0 --libs --static)" --link-flags "$(pkg-config libssh2 --libs --static)"
