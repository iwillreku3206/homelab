#!/bin/bash

echo " - Copying Caddyfile"
mkdir -p $BASE_FAST_DIR/caddy
cp caddy/Caddyfile $BASE_FAST_DIR/caddy/Caddyfile

mkdir -p $BASE_FAST_DIR/caddy_data
