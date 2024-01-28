# Kubernetes Secrets

> Kubernetes web server for checking secrets mount

![License](https://img.shields.io/badge/license-MIT-green.svg)

- Docker Container Registry
  - <https://github.com/orgs/cse-labs/packages/container/package/heartbeat>
- `make local` will build the Linux and Windows binaries locally

## Project Description

Probes

- `/healthz`
- `/readyz`
- `/version`

### Command Line Flags

- -uri URI to listen on - default: /secrets
  - Cannot be `/`
- -port port to listen on - default: 8080
  - Valid port - 1 - 64K
- -log log incoming requests to stdout - default: false
- -v display version

### Try Secrets

From a bash shell

```bash

# build the docker image
make build

# run the local docker image
make run

# check the semver
curl localhost:8080/version

# server and password
curl localhost:8080/secrets

# check the logs
docker logs heartbeat

# other options
docker run -it --rm secrets -h

# test secrets with WebV
make test

```

### CI-CD via GitHub Action

> You will need to edit the repo name and make sure you have the secrets setup

- GitHub Actions (ci-cd pipelines)
  - [Build container image](./.github/workflows/build.yaml)

## Contributing

This project welcomes contributions and suggestions and has adopted the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct.html).

For more information see the [Code of Conduct FAQ](https://www.contributor-covenant.org/faq).

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Any use of third-party trademarks or logos are subject to those third-party's policies.
