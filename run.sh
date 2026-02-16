#!/bin/bash -u

# Starts the Besu IBFT2 blockchain on Kubernetes and
# the DApp infrastructure (explorer, prometheus, grafana) on Docker Compose.

NO_LOCK_REQUIRED=true

. ./.env
. ./.common.sh

displayUsage()
{
  echo "This script deploys the Besu IBFT2 blockchain on Kubernetes"
  echo "and starts the DApp infrastructure (explorer, monitoring) via Docker Compose."
  echo "Usage: ${me} [OPTIONS]"
  echo "    -h                       : show this help."
  exit 0
}

while getopts "h" o; do
  case "${o}" in
    h)
      displayUsage
      ;;
    *)
      displayUsage
    ;;
  esac
done

composeFile="-f docker-compose_dapp.yml"

echo "${bold}*************************************"
echo "Besu IBFT2 Network (Kubernetes + DApp)"
echo "*************************************${normal}"

# ---- 1. Deploy Kubernetes blockchain ----
echo ""
echo "==> Step 1: Deploying blockchain on Kubernetes (namespace: ${K8S_NAMESPACE})..."
echo "--------------------"

kubectl apply -f ${K8S_DIR}/namespace.yaml
kubectl apply -f ${K8S_DIR}/ConfigMap.yaml
kubectl apply -f ${K8S_DIR}/HeadLess_Service.yaml

# Check secrets exist
SECRETS_OK=true
for i in 0 1 2 3; do
  if ! kubectl get secret besu-node-key-$i -n ${K8S_NAMESPACE} &>/dev/null; then
    echo "ERROR: Secret besu-node-key-$i not found in namespace ${K8S_NAMESPACE}."
    SECRETS_OK=false
  fi
done

if [ "$SECRETS_OK" = "false" ]; then
  echo ""
  echo "You must create the node key secrets first. Example:"
  echo "  kubectl create secret generic besu-node-key-0 -n ${K8S_NAMESPACE} --from-file=key=\${KEYS_PATH}/Node-1-KEY/key"
  echo "  kubectl create secret generic besu-node-key-1 -n ${K8S_NAMESPACE} --from-file=key=\${KEYS_PATH}/Node-2-KEY/key"
  echo "  kubectl create secret generic besu-node-key-2 -n ${K8S_NAMESPACE} --from-file=key=\${KEYS_PATH}/Node-3-KEY/key"
  echo "  kubectl create secret generic besu-node-key-3 -n ${K8S_NAMESPACE} --from-file=key=\${KEYS_PATH}/Node-4-KEY/key"
  echo ""
  echo "Or run:  ./create-secrets.sh"
  exit 1
fi

kubectl apply -f ${K8S_DIR}/StatefulSet.yaml
kubectl apply -f ${K8S_DIR}/RPC_Service.yaml
kubectl apply -f ${K8S_DIR}/ExternalAccess_Service.yaml

echo ""
echo "Waiting for Besu pods to be ready..."
kubectl rollout status statefulset/besu -n ${K8S_NAMESPACE} --timeout=180s

echo ""
echo "Blockchain pods:"
kubectl get pods -n ${K8S_NAMESPACE} -o wide

# ---- 2. Start DApp infrastructure (Docker Compose) ----
echo ""
echo "==> Step 2: Starting DApp infrastructure (explorer, prometheus, grafana)..."
echo "--------------------"

echo "${composeFile}" > ${LOCK_FILE}
echo "${SAMPLE_VERSION}" >> ${LOCK_FILE}

docker compose ${composeFile} build --pull
docker compose ${composeFile} up --detach

# ---- 3. List endpoints ----
echo ""
./list.sh
