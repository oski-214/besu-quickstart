#!/bin/bash -eu

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

HOST=${DOCKER_PORT_2375_TCP_ADDR:-"localhost"}

echo "${bold}*************************************"
echo "Besu IBFT2 Network (Kubernetes + DApp)"
echo "*************************************${normal}"
echo ""

# ---- Kubernetes blockchain status ----
echo "==> Kubernetes Blockchain (namespace: ${K8S_NAMESPACE})"
echo "----------------------------------"
kubectl get pods -n ${K8S_NAMESPACE} -o wide 2>/dev/null || echo "  (kubectl not available or namespace not found)"
echo ""

# ---- Docker Compose DApp status ----
echo "==> DApp Infrastructure (Docker Compose)"
echo "----------------------------------"
docker compose ${composeFile} ps
echo ""

# ---- Endpoints ----
echo "==> Endpoints"
echo "****************************************************************"
echo "JSON-RPC HTTP (via K8s NodePort)  : http://${HOST}:30545"
echo "JSON-RPC WebSocket (via K8s)      : ws://${HOST}:30800"
echo "Web block explorer                : http://${HOST}:25000/"
echo "Prometheus                        : http://${HOST}:9090/graph"
echo "Grafana                           : http://${HOST}:3000/d/XE4V0WGZz/besu-overview?orgId=1&refresh=10s&from=now-30m&to=now&var-system=All"
echo "Pet-shop DApp (after deploy)      : http://${HOST}:3001"
echo "****************************************************************"
