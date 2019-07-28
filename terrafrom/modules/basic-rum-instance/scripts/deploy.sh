#!/usr/bin/env bash

STACK_NAME="basic-rum"

docker stack deploy -c ~/.docker/services/basic-rum.yml --prune ${STACK_NAME}
