#!/bin/bash

function var_usage() {
  cat <<EOF
  No cluster is set. To set the cluster (and the region/zone where it is found), set the environment variables
  CLOUDSDK_COMPUTE_REGION=<cluster region> (regional clusters)
  CLOUDSDK_COMPUTE_ZONE=<cluster zone>
  CLOUDSDK_CONTAINER_CLUSTER=<cluster name>
EOF

  exit 1
}

cluster=$(gcloud config get-value container/cluster 2> /dev/null)
region=${CLOUDSDK_COMPUTE_REGION:-$(gcloud config get-value compute/region 2> /dev/null)}
zone=$(gcloud config get-value compute/zone 2> /dev/null)
project=$(gcloud config get-value core/project 2> /dev/null)

[[ -z "$cluster" ]] && var_usage
[ ! "$zone" -o "$region" ] && var_usage

if [ -n "$region" ]; then
  echo "Running: gcloud container clusters get-credentials --project=\"$project\" --region=\"$region\" \"$cluster\""
  gcloud container clusters get-credentials --project="$project" --region="$region" "$cluster" || exit
else
  echo "Running: gcloud container clusters get-credentials --project=\"$project\" --zone=\"$zone\" \"$cluster\""
  gcloud container clusters get-credentials --project="$project" --zone="$zone" "$cluster" || exit
 fi

echo "Running: kubectl $@" >&2
exec kubectl "$@"
#Create a new namespace:
kubectl create -f namespace-spark-cluster.yaml

#Configure kubectl to work with the new namespace:
CURRENT_CONTEXT=$(kubectl config view -o jsonpath='{.current-context}')
USER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.user}')
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.cluster}')
kubectl config set-context spark --namespace=spark-cluster --cluster=${CLUSTER_NAME} --user=${USER_NAME}
kubectl config use-context spark

#Deploy the Spark master Replication Controller and Service:
kubectl create -f spark-master-controller.yaml
kubectl create -f spark-master-service.yaml

#Next, start your Spark workers:
kubectl create -f spark-worker-controller.yaml  
