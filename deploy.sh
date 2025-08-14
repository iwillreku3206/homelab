#!/usr/bin/env bash

GPG_TTY=$(tty) gpg -o .env --decrypt --cipher-algo AES256 env

./00-networks.sh
docker compose -f 01-pihole.yml up
docker compose -f 02-cloudflared.yml up

rm .env
