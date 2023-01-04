#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
kind create cluster --config $SCRIPT_DIR/cluster-config.yaml

# Install nginx ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

while [[ $(kubectl get pods -l app.kubernetes.io/component=controller -n ingress-nginx -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for ingress pod ..." && sleep 10; done

helm repo add argo https://argoproj.github.io/argo-helm

# Install argocd
helm install argocd  argo/argo-cd --version 5.16.13 -n argocd --create-namespace -f $SCRIPT_DIR/argocd-values.yaml

while [[ $(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-application-controller -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for argocd pods ..." && sleep 10; done

# Install chartmuseum
kubectl apply -f $SCRIPT_DIR/chartmuseum.yaml
kubectl apply -f $SCRIPT_DIR/../applications/question1.yaml
kubectl apply -f $SCRIPT_DIR/../applications/question2.yaml
kubectl apply -f $SCRIPT_DIR/../applications/question3.yaml

argopass=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "=================================="
echo "YOUR ARGOCD PASSWORD IS: $argopass"
