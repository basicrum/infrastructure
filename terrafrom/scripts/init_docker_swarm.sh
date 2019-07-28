#!/usr/bin/env bash

while [ -z "$(docker info | grep CPUs)" ]; do
 echo 'Waiting for Docker to start...' && sleep 2
done

if [ "$(docker info | grep Swarm | sed 's/Swarm: //g')" == "inactive" ]; then
 docker swarm init --advertise-addr 127.0.0.1
fi
