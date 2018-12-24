version: "3.4"
services:
  # redis:
  #   image: redis:5.0
  django:
    image: ${web_image}
    command: uwsgi
    environment:
      PORT: "8000"
      DATABASE_URL: "$${DATABASE_URL}"
      ALLOWED_HOSTS: "$${APPLICATION_DOMAIN}"
    deploy:
      labels:
        traefik.port: 8000
        traefik.docker.network: traefik-net
        traefik.frontend.rule: "Host: $${APPLICATION_DOMAIN}"
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3
    networks:
      - traefik-net
  # celery:
  #   image: ${web_image}
  #   command: celery
  # celerybeat:
  #   image: ${web_image}
  #   command: beat
  traefik:
    image: traefik:1.7
    command: |
      --api.entryPoint=api --api.dashboard=true
      --docker --docker.swarmMode=true --docker.endpoint=unix:///var/run/docker.sock
      --entryPoints="Name:api Address::8080"
      --entryPoints="Name:http Address::80"
      --entryPoints="Name:https Address::443 TLS"
      --acme.email=$${ACME_EMAIL} --acme.entryPoint=https
      --acme.storage=acme.json --acme.tlsChallenge=true --acme.onHostRule=true
    networks:
      - traefik-net
    ports:
      - 80:80
      - 443:443
      - 8080:8080
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${base_path}/acme.json:/acme.json
networks:
  traefik-net:
    external: true
