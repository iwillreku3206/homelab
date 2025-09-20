#!/usr/bin/env bash

if ! command -v mongosh -h >/dev/null 2>&1; then
  wget -qO- https://www.mongodb.org/static/pgp/server-8.0.asc | tee /etc/apt/trusted.gpg.d/server-8.0.asc
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
  apt update
  apt install -y mongodb-mongosh
fi

if [ -z "${MONGO_ROOT_PASSWORD}" ]; then
  apt install -y gpg

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
fi


create_mongo_user() {
  local username="$1"
  local password="$2"
  local dbname="$1"

  if [[ -z "$username" || -z "$password" || -z "$dbname" ]]; then
    echo "Usage: create_mongo_user <username> <password> <database>"
    return 1
  fi

  mongosh "mongodb://root:$MONGO_ROOT_PASSWORD_ESCAPEDD@localhost:27017/$dbname" --eval "db.createUser({
    user: '$username',
    pwd: '$password',
    roles: [{ role: 'readWrite', db: '$dbname' }]
  })"
}

create_mongo_user "rocketchat" "$ROCKET_CHAT_MONGO_PASS"
