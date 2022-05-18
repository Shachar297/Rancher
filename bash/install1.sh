#!/bin/bash -x



### Variables

CLUSTER_NAME=rancher-cluster
CERT_MANAGER_RELEASE=v1.8.0



### Clear prevoius content

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

kubectl delete namespace cattle-system
kubectl delete namespace cert-manager

### Install k3 & other tools on MacOS

brew install k3d kubectl helm



### Install k3s - Will be used later on for Rancher

wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash



### Create a k3d cluster. Use the loadbalancer provided by k3d

k3d cluster create \
    $CLUSTER_NAME \
    --api-port 6550 \
    --servers 1 \
    --agents 3 \
    --port 443:443@loadbalancer \
    --wait



### Verify the installation

k3d cluster list



### Add the k3s to the kubeconfig

k3d kubeconfig merge \
    $CLUSTER_NAME \
    --kubeconfig-switch-context

### Add the newelwy created cluster

kubectl get nodes

### Get the pods status in the background

kubectl get pods -A --watch &

### Add the required helm charts

helm repo add rancher https://releases.rancher.com/server-charts/latest
helm repo add jetstack https://charts.jetstack.io

### Create the namespace(s) for Rancher & cert-manager

kubectl create namespace cattle-system
kubectl create namespace cert-manager



# Install cert-manager

kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/${CERT_MANAGER_RELEASE}/cert-manager.crds.yaml

# Add cert-manager helm repo

helm repo update

### Install Cert-manager

helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version ${CERT_MANAGER_RELEASE} --wait

### Verify cert-manager installation

kubectl rollout status \
    -n cert-manager \
    deploy/cert-manager


### Install racnher

helm install rancher \
    rancher/rancher \
    --namespace cattle-system \
    --set hostname=rancher.k3d.localhost \
    --wait


### Verify rancher installation

kubectl rollout status \
    -n cattle-system \
    deploy/rancher


### Open broswer in: https://rancher.k3d.localhost

######

###### Important, once on this page type; thisisunsafe

######