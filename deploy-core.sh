#!/usr/bin/env bash

set -e

apt-get install -y gpg rsync

read -s -p "Enter ENV Password: " GPG_PASS

gpg --batch --yes --decrypt \
    --passphrase "$GPG_PASS" \
    --cipher-algo AES256 \
    -o .env \
    env

set -a
source .env
set +a
rm .env

echo "Adding networks..."
./00-networks.sh

echo "Deploying PiHole..."
mkdir -p $BASE_FAST_DIR/pihole
docker compose -f 01-pihole.yml up -d

echo "Deploying Cloudflared..."
docker stack deploy -d -c 02-cloudflared.yml cloudflared

echo "Deploying Caddy..."
./03-caddy.sh
docker stack deploy -d -c 03-caddy.yml caddy

echo "Deploying MongoDB..."
mkdir -p $BASE_FAST_DIR/mongodb/{db,config}
echo -ne "$MONGO_KEYFILE" > /etc/mongo-keyfile
chown 999:999 /etc/mongo-keyfile
chmod 400 /etc/mongo-keyfile
docker stack deploy -d -c 05-mongo.yml mongo

echo "Deploying PostgreSQL..."
mkdir -p $BASE_FAST_DIR/postgres
docker stack deploy -d -c 06-postgres.yml postgres

echo "Deploying Redis..."
docker stack deploy -d -c 07-redis.yml redis

echo "Deploying Authentik..."
mkdir -p $BASE_FAST_DIR/authentik/media
mkdir -p $BASE_FAST_DIR/authentik/templates
mkdir -p $BASE_FAST_DIR/authentik/certs
docker stack deploy -d -c 08-authentik.yml authentik

echo "Deploy AD Self Service"
source 09-ad-selfservice.sh
docker stack deploy -d -c 09-ad-selfservice.yml ad-selfservice

echo "Deploy Prometheus"
mkdir -p $BASE_FAST_DIR/prometheus/data
echo " - Copying configuration"
cp -r prometheus/* $BASE_FAST_DIR/prometheus
docker stack deploy -d -c 10-prometheus.yml prometheus
