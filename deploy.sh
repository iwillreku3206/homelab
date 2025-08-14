#!/usr/bin/env bash

set -e

read -s -p "Enter ENV Password: " GPG_PASS

gpg --batch --yes --decrypt \
    --passphrase "$GPG_PASS" \
    --cipher-algo AES256 \
    -o .env \
    env

set -a
source .env
set +a

echo "Adding networks..."
./00-networks.sh

echo "Deploying PiHole..."
docker compose -f 01-pihole.yml up -d

echo "Deploying Cloudflared..."
docker stack deploy -d -c 02-cloudflared.yml cloudflared

echo "Deploying Caddy"
./03-caddy.sh

docker stack deploy -d -c 03-caddy.yml caddy

rm .env
