#!/bin/bash
set -eu

if [[ ${K8S_CI_DYNNS:-NOP} != "NOP" && ${CI_ENVIRONMENT_SLUG:-NOP} != "NOP" ]]; then
    K8S_DEPLOY_SA_TOKEN_NAME="K8S_API_TOKEN_$(echo "$CI_ENVIRONMENT_SLUG"|awk '{ gsub(/-/, "_"); print toupper($0) }')"
    K8S_CI_TOKEN=${!K8S_DEPLOY_SA_TOKEN_NAME}
fi

kubectl config set-cluster "$K8S_CLUSTER_NAME" --insecure-skip-tls-verify=true --server="$K8S_API_URL"

if [[ ${K8S_CI_TOKEN:-NOP} != "NOP" ]]; then
    kubectl config set-credentials ci --token="$K8S_CI_TOKEN"
elif [[ -f /run/secrets/kubernetes.io/serviceaccount/token ]]; then
    kubectl config set-credentials ci --token="$(cat /run/secrets/kubernetes.io/serviceaccount/token)"
else
    echo "Error: ServiceAccount token not set" >&2
    false
fi

kubectl config set-context ci --cluster="$K8S_CLUSTER_NAME" --user=ci
kubectl config use-context ci

exec "$@"
