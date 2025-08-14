#!/usr/bin/env bash

gpg -o .env --decrypt --cipher-algo AES256 env

./00-networks.sh
docker compose -f 02-pihole.yml up
docker compose -f 02-pihole.yml up

rm .env
