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

# $1: name
# $2: password

send_sql() {
  echo "> $1"
  echo $1 > /tmp/postgres.fifo
}

create_database() {
  send_sql "SELECT 'CREATE DATABASE $1'"
  send_sql "WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$1')\gexec"

  send_sql "DO"
  send_sql   "\$do$"
  send_sql   "BEGIN"
  send_sql      "IF EXISTS ("
  send_sql         "SELECT FROM pg_catalog.pg_roles"
  send_sql         "WHERE  rolname = '$1') THEN"

  send_sql         "RAISE NOTICE 'Role \"$1\" already exists. Skipping.';"
  send_sql      "ELSE"
  send_sql         "BEGIN" 
  send_sql            "CREATE ROLE $1 LOGIN PASSWORD '$2';"
  send_sql         "EXCEPTION"
  send_sql            "WHEN duplicate_object THEN"
  send_sql               "RAISE NOTICE 'Role \"$1\" was just created by a concurrent transaction. Skipping.';"
  send_sql         "END;"
  send_sql      "END IF;"
  send_sql   "END"
  send_sql   "\$do$;"

  send_sql "GRANT ALL PRIVILEGES ON DATABASE $1 TO $1;"
  send_sql "\c $1"
  send_sql "GRANT ALL ON SCHEMA public TO $1;"
  send_sql "ALTER DEFAULT PRIVILEGES IN SCHEMA public"
  send_sql     "GRANT ALL ON TABLES TO $1;"
  send_sql "ALTER DEFAULT PRIVILEGES IN SCHEMA public"
  send_sql     "GRANT ALL ON SEQUENCES TO $1;"
}

create_database "authentik" "$AUTHENTIK_PG_PASS"

create_database "jellyseerr" "$JELLYSEERR_PG_PASS"

echo \\q > /tmp/postgres.fifo
echo "" > /tmp/postgres.fifo

wait $BACK_PID
rm /tmp/postgres.fifo
