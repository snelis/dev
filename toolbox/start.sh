#!/bin/bash

CMD=${1:-zsh}
docker run --rm \
  -h toolbox \
  -ti \
  --net=host \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube/config:/home/${USER}/.kube/config \
  -v ~/:/mnt/home \
  -v "`pwd`":/workdir \
  -w /workdir \
  toolbox ${CMD}
