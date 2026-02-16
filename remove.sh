#!/bin/bash -u

# Removes everything: K8s blockchain resources + Docker Compose DApp infrastructure.

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

removeDockerImage(){
  if [[ ! -z `docker ps -a | grep $1` ]]; then
    docker image rm $1
  fi
}

echo "${bold}*************************************"
echo "Removing Besu IBFT2 Network"
echo "*************************************${normal}"

# ---- 1. Remove Docker Compose DApp ----
echo "Removing DApp infrastructure (Docker Compose)..."
docker compose ${composeFile} down -v
docker compose ${composeFile} rm -sfv

removeDockerImage sample-network/block-explorer-light:${BESU_VERSION}

# ---- 2. Remove Kubernetes blockchain ----
echo ""
echo "Removing Kubernetes blockchain resources (namespace: ${K8S_NAMESPACE})..."
kubectl delete -f ${K8S_DIR}/ExternalAccess_Service.yaml --ignore-not-found
kubectl delete -f ${K8S_DIR}/RPC_Service.yaml --ignore-not-found
kubectl delete -f ${K8S_DIR}/StatefulSet.yaml --ignore-not-found
kubectl delete -f ${K8S_DIR}/HeadLess_Service.yaml --ignore-not-found
kubectl delete -f ${K8S_DIR}/ConfigMap.yaml --ignore-not-found

# Delete PVCs (blockchain data)
echo "Deleting PersistentVolumeClaims..."
kubectl delete pvc -n ${K8S_NAMESPACE} -l app=besu --ignore-not-found

echo ""
echo "NOTE: Secrets (node keys) and namespace '${K8S_NAMESPACE}' are NOT deleted."
echo "To delete everything including secrets:"
echo "  kubectl delete namespace ${K8S_NAMESPACE}"

rm -f ${LOCK_FILE}
echo "Lock file ${LOCK_FILE} removed"
echo "Done."
