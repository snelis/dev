# Getting started

# Requirements
- docker
- kind
- kubectl
- stern
- kustomize

## 1. Create a kubernetes development cluster
```bash
make cluster
```

## 2. Ensure the demo works
```bash
make demo
```



# Use the toolbox (work in progress)

The toolbox is a docker container with a bunch of tooling.

To build the toolbox
```bash
make toolbox
```

To a shell with the toolbox:
```bash
make shell
```
