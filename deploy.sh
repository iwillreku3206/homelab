#!/usr/bin/env bash

set -e

read -s -p "Enter ENV Password: " GPG_PASS

gpg --batch --yes --decrypt \
    --passphrase "$GPG_PASS" \
    --cipher-algo AES256 \
    -o .env \
    env


echo "Adding networks..."
./00-networks.sh

echo "Deploying PiHole..."
docker compose -d -f 01-pihole.yml up

echo "Deploying Cloudflared..."
docker stack deploy -d -c 02-cloudflared.yml

rm .env
