#!/bin/bash

echo " - Copying Caddyfile"
mkdir -p $BASE_FAST_DIR/caddy/{data,config,etc}
cp caddy/Caddyfile $BASE_FAST_DIR/caddy/Caddyfile
