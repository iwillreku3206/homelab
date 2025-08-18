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

psql -h $CORE_INTERNAL_IP -p 5432 -U postgres -W < /tmp/postgres.fifo &

echo $POSTGRES_ROOT_PASSWORD > /tmp/postgres.fifo

# Create the database
echo CREATE DATABASE authentik\; > /tmp/postgres.fifo

# Create the user with a password (replace 'yourpassword'!)
echo CREATE USER authentik WITH PASSWORD \'$AUTHENTIK_PG_PASS\'\; > /tmp/postgres.fifo

# Give the user full privileges on the database
echo GRANT ALL PRIVILEGES ON DATABASE authentik TO authentik\; > /tmp/postgres.fifo

# Grant schema privilages

echo \c authentik >> /tmp/postgres.fifo
echo GRANT ALL ON SCHEMA public TO authentik\; > /tmp/postgres.fifo
echo ALTER DEFAULT PRIVILEGES IN SCHEMA public > /tmp/postgres.fifo
echo     GRANT ALL ON TABLES TO authentik\; > /tmp/postgres.fifo
echo ALTER DEFAULT PRIVILEGES IN SCHEMA public > /tmp/postgres.fifo
echo     GRANT ALL ON SEQUENCES TO authentik\; > /tmp/postgres.fifo

rm /tmp/postgres.fifo
