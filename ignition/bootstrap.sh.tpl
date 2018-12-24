#!/bin/bash
set -e

if [ -f ${base_path}/.done ]; then
    exit
fi

export DATABASE_URL=${database_url}
export ACME_EMAIL=${acme_email}
export APPLICATION_DOMAIN=${application_domain}

touch ${base_path}/acme.json && chmod 600 ${base_path}/acme.json
docker swarm init --advertise-addr ens4v1
docker pull ${web_image}
docker network create --driver overlay --subnet=10.0.9.0/24 traefik-net
docker stack deploy -c ${base_path}/stack.yml web

touch ${base_path}/.done
