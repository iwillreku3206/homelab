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
docker stack deploy -d -c 08-authentik.yml authentik

