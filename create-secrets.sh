#!/bin/bash -u
# Creates Kubernetes secrets for the Besu node keys.
# Run this ONCE before ./run.sh

. ./.env

echo "Creating Besu node key secrets in namespace ${K8S_NAMESPACE}..."
echo "Using keys from: ${KEYS_PATH}"
echo ""

# Ensure namespace exists
kubectl apply -f ${K8S_DIR}/namespace.yaml

for i in 0 1 2 3; do
  NODE_NUM=$((i + 1))
  SECRET_NAME="besu-node-key-$i"
  KEY_FILE="${KEYS_PATH}/Node-${NODE_NUM}-KEY/key"

  if [ ! -f "$KEY_FILE" ]; then
    echo "ERROR: Key file not found: $KEY_FILE"
    echo "  Update KEYS_PATH in .env to point to your node keys directory."
    exit 1
  fi

  # Delete existing secret if present, then recreate
  kubectl delete secret ${SECRET_NAME} -n ${K8S_NAMESPACE} --ignore-not-found
  kubectl create secret generic ${SECRET_NAME} -n ${K8S_NAMESPACE} --from-file=key=${KEY_FILE}
  echo "  Created secret ${SECRET_NAME} from ${KEY_FILE}"
done

echo ""
echo "All secrets created successfully."
