#!/usr/bin/env bash

set -e

apt-get install -y gpg

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

echo "Deploying Jellyfin..."
mkdir -p $BASE_FAST_DIR/jellyfin/config
docker stack deploy -d -c 20-jellyfin.yml jellyfin

echo "Deploying Jellyseerr..."
mkdir -p $BASE_FAST_DIR/jellyseerr/config
docker stack deploy -d -c 21-jellyseerr.yml jellyseerr

echo "Deploying Qbittorrent..."
mkdir -p $BASE_FAST_DIR/qbit/config
docker stack deploy -d -c 25-qbit.yml qbittorrent

echo "Deploying Radarr..."
mkdir -p $BASE_FAST_DIR/radarr/config
docker stack deploy -d -c 30-radarr.yml radarr

echo "Deploying Sonarr..."
mkdir -p $BASE_FAST_DIR/sonarr/config
docker stack deploy -d -c 31-sonarr.yml sonarr

echo "Deploying Lidarr..."
mkdir -p $BASE_FAST_DIR/lidarr/config
docker stack deploy -d -c 32-lidarr.yml lidarr

echo "Deploying Prowlarr..."
mkdir -p $BASE_FAST_DIR/prowlarr/config
docker stack deploy -d -c 34-prowlarr.yml prowlarr

echo "Deploying Bazarr..."
mkdir -p $BASE_FAST_DIR/bazarr/config
docker stack deploy -d -c 35-bazarr.yml bazarr

echo "Deploying Forgejo..."
echo $TZ > /etc/timezone
mkdir -p $BASE_FAST_DIR/forgejo
docker stack deploy -d -c 40-forgejo.yml forgejo

echo "Deploying Rocket Chat..."
docker stack deploy -d -c 41-rocket-chat.yml rocket-chat

echo "Deploying Overleaf..."
mkdir -p $BASE_FAST_DIR/overleaf
docker stack deploy -d -c 42-overleaf.yml overleaf
