#!/bin/bash
openssl req -new -newkey rsa:4096 -nodes -keyout $1.key -out $1.csr -subj "/CN=$1"

REQUEST=$(cat $1.csr | base64)

cat <<EOF > $1.yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: $1
spec:
  groups:
  - system:authenticated
  request: ${REQUEST}
  usages:
  - client auth
EOF

kubectl create -f $1.yaml

kubectl certificate approve $1

kubectl get csr $1 -o jsonpath='{.status.certificate}' | base64 -d > $1.crt

kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' --raw | base64 --decode - > k8s-ca.crt

kubectl config set-cluster $(kubectl config view -o jsonpath='{.clusters[0].name}') --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=k8s-ca.crt --kubeconfig=$1-k8s-config --embed-certs

kubectl config set-credentials $1 --client-certificate=$1.crt --client-key=$1.key --embed-certs --kubeconfig=$1-k8s-config

kubectl config set-context $1@maf.prod --cluster=$(kubectl config view -o jsonpath='{.clusters[0].name}') --namespace=default --user=$1 --kubeconfig=$1-k8s-config

kubectl config use-context $1@maf.prod --kubeconfig=$1-k8s-config