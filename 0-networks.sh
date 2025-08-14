#!/usr/bin/env bash

# dns network
docker network create --driver bridge --subnet 172.32.1.252/30 --gateway 172.32.1.253 --scope local dns
