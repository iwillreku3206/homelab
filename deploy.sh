#!/usr/bin/env bash


read -s -p "Enter ENV Password: " GPG_PASS

gpg --passphrase "$GPG_PASS" -o .env --decrypt --cipher-algo AES256 env

./00-networks.sh
docker compose -f 01-pihole.yml up
docker compose -f 02-cloudflared.yml up

rm .env
