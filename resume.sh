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

# Restart port-forward
echo ""
echo "Starting kubectl port-forward (background)..."
pkill -f "kubectl port-forward.*besu" 2>/dev/null || true
sleep 1
kubectl port-forward svc/besu-rpc-external 30545:8545 30800:8546 30950:9545 -n ${K8S_NAMESPACE} &>/dev/null &
echo $! > .port-forward.pid
for i in 1 2 3; do
  kubectl port-forward svc/besu-${i}-metrics-external 3095${i}:9545 -n ${K8S_NAMESPACE} &>/dev/null &
  echo $! >> .port-forward.pid
done
sleep 2
echo "Port-forwards active."

echo ""
./list.sh
