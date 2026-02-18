#!/bin/bash -u

# Copyright 2018 ConsenSys AG.
# Modified for K8s + DApp architecture (TFG)

. ./.env

echo "*************************************"
echo "DApp Pet-Shop Deployment"
echo "*************************************"

# Verificar que port-forward está activo (run.sh lo inicia)
if ! curl -s http://localhost:30545 -X POST -H 'Content-Type: application/json' \
     -d '{"jsonrpc":"2.0","method":"net_version","id":1}' --connect-timeout 3 &>/dev/null; then
  echo "WARNING: No se puede conectar a localhost:30545"
  echo "Asegúrate de que ./run.sh esté ejecutado (inicia port-forward automáticamente)."
  echo "O inicia port-forward manualmente:"
  echo "  kubectl port-forward svc/besu-rpc-external 30545:8545 30800:8546 -n ${K8S_NAMESPACE} &"
  exit 1
fi
echo "Conexión OK: localhost:30545"

# Configurar npm global sin sudo (evita EACCES)
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH

# Instalar truffle globalmente si no está disponible
if ! command -v truffle &> /dev/null; then
    echo "Installing Truffle globally..."
    npm install -g truffle
fi

cd pet-shop

echo ""
echo "Installing pet-shop dependencies..."
npm install

echo ""
echo "Compiling and migrating contracts to K8s network (localhost:30545 via port-forward)..."
truffle migrate --network sampleNetworkWallet --reset

echo ""
echo "Starting DApp on http://localhost:3001 ..."
npm run dev

