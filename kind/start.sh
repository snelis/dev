#!/bin/env bash

set -u
set -e

COMMAND="\e[92m"
HEADER="\e[96m"
COMMENT="\e[33m"
ENDCOLOR="\e[0m"

function header () {
  echo -e "${HEADER}$*${ENDCOLOR}"
  echo "------------------------------------"
}

function comment () {
  echo -e "${COMMENT}$*${ENDCOLOR}"
}

function run () {
  echo -e "> ${COMMAND}$*${ENDCOLOR}"
  # read -r
  trap "echo " EXIT INT TERM
  bash -c "$*"
  trap - EXIT INT TERM
  echo ""
}

header Creating a local kubernetes with kind

if ! kind get clusters | grep -E "^kind$" >/dev/null ; then
  run kind create cluster --config=kind/config.yaml
fi

header Creating calico networking
run kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calico.yaml
run kubectl -n kube-system wait --for=condition=Ready pods -l k8s-app=calico-node --timeout=90s
run kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true

header Creating the nginx ingress
run kubectl apply -f kind/ingress-nginx.yaml

header Creating the registry definition
run kubectl apply -f kind/registry.yaml

header Wait for the ingress to become available
run kubectl -n ingress-nginx wait --for=condition=Complete job/ingress-nginx-admission-create
run kubectl -n ingress-nginx wait --for=condition=Complete job/ingress-nginx-admission-patch
run kubectl -n ingress-nginx wait --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s


