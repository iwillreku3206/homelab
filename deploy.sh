#!/usr/bin/env bash

set -e

read -s -p "Enter ENV Password: " GPG_PASS

gpg --batch --yes --decrypt \
    --passphrase "$GPG_PASS" \
    --cipher-algo AES256 \
    -o .env \
    env

./00-networks.sh
docker compose -f 01-pihole.yml up
docker compose -f 02-cloudflared.yml up

rm .env
