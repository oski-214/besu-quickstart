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

echo "Stopping kubectl port-forward..."
if [ -f .port-forward.pid ]; then
  while read pid; do
    kill $pid 2>/dev/null
  done < .port-forward.pid
  rm -f .port-forward.pid
fi
pkill -f "kubectl port-forward.*besu" 2>/dev/null || true

echo "Scaling down Kubernetes StatefulSet to 0..."
kubectl scale statefulset besu -n ${K8S_NAMESPACE} --replicas=0

echo "Network stopped."
