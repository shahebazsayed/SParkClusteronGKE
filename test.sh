#!/bin/bash

gcloud container clusters get-credentials spark-on-gke --zone us-central1-f --project sparkonk8
kubectl create -f namespace-spark-cluster.yaml
CURRENT_CONTEXT=$(kubectl config view -o jsonpath='{.current-context}')
USER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.user}')
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.cluster}')
kubectl config set-context spark --namespace=spark-cluster --cluster=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.cluster}') --user=${USER_NAME}
kubectl config use-context spark
kubectl create -f spark-master-controller.yaml
kubectl create -f spark-master-service.yaml
kubectl create -f spark-worker-controller.yaml
