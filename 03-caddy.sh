#!/bin/bash

echo " - Copying Caddyfile"
mkdir -p $BASE_FAST_DIR/caddy
cp caddy/Caddyfile $BASE_FAST_DIR/caddy/Caddyfile

docker volume inspect caddy_data > /dev/null 2>&1

if [ $? -ne 0 ]; then
  docker network create \
    caddy_data
fi
