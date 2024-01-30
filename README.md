# Kubernetes Secrets

> Kubernetes web server for checking secrets mount

![License](https://img.shields.io/badge/license-MIT-green.svg)

## Project Description

Do NOT deploy this to production! This is for testing that your secrets are correctly set during development.

## Probes

- `/healthz`
- `/readyz`
- `/version`

### Command Line Flags

- -uri URI to listen on - default: /secrets
  - Cannot be `/`
- -port port to listen on - default: 8080
- -log log incoming requests to stdout - default: false
- -v display version

### Try Secrets

From a bash shell

```bash

# build the docker image
make build

# run the local docker image
make run

# check the secrets (from ./secretsvol)
curl localhost:8080/secrets

```

## Deploy Secrets to Kubernetes

```bash

## create a K3d cluster in your Codespaces
kic cluster create

## create the secrets namespace
kubectl create ns secrets

## add secrets
kubectl create secret generic sample -n secrets \
    --from-literal=server="k8s-server" \
    --from-literal=password="k8s-pwd"

# deploy to k8s
kubectl apply -f deploy

# check pods
kubectl get pods -n secrets

# check values
http localhost:30080/secrets

```

## Contributing

This project welcomes contributions and suggestions and has adopted the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct.html).

For more information see the [Code of Conduct FAQ](https://www.contributor-covenant.org/faq).

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Any use of third-party trademarks or logos are subject to those third-party's policies.
