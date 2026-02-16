#!/bin/bash -u

# Resumes the previously stopped network (K8s blockchain + Docker Compose DApp).

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

echo "${bold}*************************************"
echo "Resuming Besu IBFT2 Network"
echo "*************************************${normal}"

echo "Scaling up Kubernetes StatefulSet to 4..."
kubectl scale statefulset besu -n ${K8S_NAMESPACE} --replicas=4
kubectl rollout status statefulset/besu -n ${K8S_NAMESPACE} --timeout=180s

echo "Resuming DApp infrastructure (Docker Compose)..."
docker compose ${composeFile} start

echo ""
./list.sh
