#!/usr/bin/env bash

gpg -o env --symmetric --cipher-algo AES256 .env
