# Deploy proxy
TODO: add description on how to deploy traefik proxy

# Prepare directory (optional)

```shell
mkdir -p pardubicky-hacker
cd pardubicky-hacker
```

# Deploy swarm stack

```shell
docker stack deploy -c stack.yml pardubicky-hacker
```

# Deploy compose judgehosts

```shell
docker compose -f compose.yml up -d
```
