#!/bin/bash -u

# Stops the DApp infrastructure (Docker Compose) and scales down K8s blockchain.

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

echo "${bold}*************************************"
echo "Stopping Besu IBFT2 Network"
echo "*************************************${normal}"

echo "Stopping DApp infrastructure (Docker Compose)..."
docker compose ${composeFile} stop

echo "Scaling down Kubernetes StatefulSet to 0..."
kubectl scale statefulset besu -n ${K8S_NAMESPACE} --replicas=0

echo "Network stopped."
