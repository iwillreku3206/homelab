#!/usr/bin/env bash

apt install -y postgresql-client

mkfifo /tmp/postgres.fifo

if [ -z "${POSTGRES_ROOT_PASSWORD}" ]; then
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

PGPASSWORD="$POSTGRES_ROOT_PASSWORD" psql -h $CORE_INTERNAL_IP -p 5432 -U postgres < /tmp/postgres.fifo 2>&1 | (echo -n '<<< ' && cat) &
BACK_PID=$!

create_mongo_user() {
  local username="$1"
  local password="$2"
  local dbname="$1"

  if [[ -z "$username" || -z "$password" || -z "$dbname" ]]; then
    echo "Usage: create_mongo_user <username> <password> <database>"
    return 1
  fi

  mongosh "$MONGO_ROOT_PASSWORD/$dbname" --eval "db.createUser({
    user: '$username',
    pwd: '$password',
    roles: [{ role: 'readWrite', db: '$dbname' }]
  })"
}

create_mongo_user "rocketchat" "$ROCKET_CHAT_MONGO_PASS"
