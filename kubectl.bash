#!/bin/bash

cluster=$(gcloud config get-value container/cluster 2> /dev/null)
region=${CLOUDSDK_COMPUTE_REGION:-$(gcloud config get-value compute/region 2> /dev/null)}
zone=$(gcloud config get-value compute/zone 2> /dev/null)
project=$(gcloud config get-value core/project 2> /dev/null)

if [ -n "$region" ]; then
  echo "Running: gcloud container clusters get-credentials --project=\"$project\" --region=\"$region\" \"$cluster\""
  gcloud container clusters get-credentials --project="$project" --region="$region" "$cluster" || exit
else
  echo "Running: gcloud container clusters get-credentials --project=\"$project\" --zone=\"$zone\" \"$cluster\""
  gcloud container clusters get-credentials --project="$project" --zone="$zone" "$cluster" || exit
 fi

echo "Running: kubectl $@" >&2
exec kubectl "$@"
