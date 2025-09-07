#!/usr/bin/env bash

# dns network
docker network inspect dns > /dev/null 2>&1

if [ $? -ne 0 ]; then
  docker network create \
    --driver bridge \
    --subnet 172.32.1.252/30 \
    --gateway 172.32.1.253 \
    --scope local \
    --attachable \
    dns
fi

# apps network
docker network inspect apps > /dev/null 2>&1

if [ $? -ne 0 ]; then
  docker network create \
    --driver overlay \
    --subnet 172.128.0.0/16 \
    --gateway 172.128.0.1 \
    --scope swarm \
    --attachable \
    apps
fi

# mariadb network
docker network inspect mariadb > /dev/null 2>&1

if [ $? -ne 0 ]; then
  docker network create \
    --driver overlay \
    --subnet 172.129.0.0/16 \
    --gateway 172.129.0.1 \
    --scope swarm \
    --attachable \
    mariadb
fi
# mongodb network
docker network inspect mongodb > /dev/null 2>&1

if [ $? -ne 0 ]; then
  docker network create \
    --driver overlay \
    --subnet 172.130.0.0/16 \
    --gateway 172.130.0.1 \
    --scope swarm \
    --attachable \
    mongodb
fi
# postgres network
docker network inspect postgres > /dev/null 2>&1

if [ $? -ne 0 ]; then
  docker network create \
    --driver overlay \
    --subnet 172.131.0.0/16 \
    --gateway 172.131.0.1 \
    --scope swarm \
    --attachable \
    postgres
fi
# redis network
docker network inspect redis > /dev/null 2>&1

if [ $? -ne 0 ]; then
  docker network create \
    --driver overlay \
    --subnet 172.132.0.0/16 \
    --gateway 172.132.0.1 \
    --scope swarm \
    --attachable \
    redis
fi

# prometheus network
docker network inspect prometheus > /dev/null 2>&1

if [ $? -ne 0 ]; then
  docker network create \
    --driver overlay \
    --subnet 172.133.0.0/16 \
    --gateway 172.133.0.1 \
    --scope swarm \
    --attachable \
    prometheus
fi
