#!/usr/bin/env bash

STACK_NAME="basic-rum"
export LETSENCRYPT_EMAIL="${EMAIL}"
export DOMAIN="${DOMAIN}"

docker stack deploy -c ~/.docker/services/basic-rum.yml --prune $STACK_NAME
