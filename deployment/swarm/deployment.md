# Deploy the swarm stack

Create docker remote context

```shell
docker context create <custom-name> --docker "host=ssh://<USER>@<IP>:<PORT>"
```

Create/update docker stack on the swarm

```shell
docker --context <custom-name> \
  stack deploy \
  --compose-file stack.yml \
  --prune --with-registry-auth \
  pardubicky-hacker
```

# Deploy compose judgehosts

```shell
docker --context <custom-name> compose \
  --file compose.yml \
  --project-name pardubicky-hacker \
  up --detach --remove-orphans
```
