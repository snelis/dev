#!/bin/bash

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

# header Creating calico networking
# run kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calico.yaml
# run kubectl -n kube-system wait --for=condition=Ready pods -l k8s-app=calico-node --timeout=900s
# run kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true

header Creating the nginx ingress
run kubectl apply -f kind/ingress-nginx.yaml

header Creating the registry definition
run kubectl apply -f kind/registry.yaml

header Wait for the ingress to become available
run kubectl -n ingress-nginx wait --for=condition=Complete job/ingress-nginx-admission-create --timeout=900s
run kubectl -n ingress-nginx wait --for=condition=Complete job/ingress-nginx-admission-patch --timeout=900s
run kubectl -n ingress-nginx wait --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=900s

header Create SecretProviderClass
run helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
run helm repo update
run helm upgrade -i csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
run kubectl -n kube-system wait --for=condition=Ready pods -l app.kubernetes.io/name=secrets-store-csi-driver --timeout=900s

# run helm repo add hashicorp https://helm.releases.hashicorp.com
# run helm repo update
# run helm install vault hashicorp/vault \
#     --set "server.dev.enabled=true" \
#     --set "injector.enabled=false" \
#     --set "csi.enabled=true"
# run kubectl -n default wait --for=condition=Ready pods -l app.kubernetes.io/name=vault-csi-provider --timeout=900s

# kubectl exec -i vault-0 -- vault kv put secret/app oidc-rp-client-id=1337 oidc-rp-client-secret=supersecret
# kubectl exec -i vault-0 -- vault kv get secret/app
# kubectl exec -i vault-0 -- vault auth enable kubernetes
# kubectl exec -it vault-0 -- sh -c '
# vault write auth/kubernetes/config \
#     kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
# '

# kubectl exec -it vault-0 -- sh -c '
# vault policy write dev - <<EOF
# path "*" {
#   capabilities = ["read"]
# }
# '

# kubectl exec -it vault-0 -- sh -c '
# vault write auth/kubernetes/role/dev \
#     bound_service_account_names=default \
#     bound_service_account_namespaces=default \
#     policies=dev \
#     ttl=20m
# '
