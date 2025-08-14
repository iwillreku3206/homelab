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
