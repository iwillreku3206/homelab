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

PGPASSWORD="$POSTGRES_ROOT_PASSWORD" psql -h $CORE_INTERNAL_IP -p 5432 -U postgres < /tmp/postgres.fifo &

# $1: name
# $2: password
create_database() {
  echo CREATE DATABASE IF NOT EXISTS $1\; > /tmp/postgres.fifo
  echo CREATE USER IF NOT EXISTS $1 WITH PASSWORD \'$2\'\; > /tmp/postgres.fifo
  echo GRANT ALL PRIVILEGES ON DATABASE $1 TO $1\; > /tmp/postgres.fifo
  echo \\c $1 >> /tmp/postgres.fifo
  echo GRANT ALL ON SCHEMA public TO $1\; > /tmp/postgres.fifo
  echo ALTER DEFAULT PRIVILEGES IN SCHEMA public > /tmp/postgres.fifo
  echo     GRANT ALL ON TABLES TO $1\; > /tmp/postgres.fifo
  echo ALTER DEFAULT PRIVILEGES IN SCHEMA public > /tmp/postgres.fifo
  echo     GRANT ALL ON SEQUENCES TO $1\; > /tmp/postgres.fifo
  echo \\q > /tmp/postgres.fifo
  echo "" > /tmp/postgres.fifo
}

create_database "authentik" "$AUTHENTIK_PG_PASS"
create_database "jellyseerr" "$JELLYSEERR_PG_PASS"


rm /tmp/postgres.fifo
