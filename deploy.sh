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
mkdir -p $BASE_FAST_DIR/pihole
docker compose -f 01-pihole.yml up -d

echo "Deploying Cloudflared..."
docker stack deploy -d -c 02-cloudflared.yml cloudflared

echo "Deploying Caddy"
./03-caddy.sh
docker stack deploy -d -c 03-caddy.yml caddy

echo "Deploying PostgreSQL"
mkdir -p $BASE_FAST_DIR/postgres
docker stack deploy -d -c 06-postgres.yml postgres

echo "Deploying Redis"
docker stack deploy -d -c 07-redis.yml redis

echo "Deploying Authentik"
mkdir -p $BASE_FAST_DIR/authentik/media
mkdir $BASE_FAST_DIR/authentik/templates
mkdir $BASE_FAST_DIR/authentik/certs
docker stack deploy -d -c 08-authentik.yml authentik

rm .env
