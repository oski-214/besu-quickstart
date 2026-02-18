#!/bin/bash -u

# Copyright 2018 ConsenSys AG.
# Modified for K8s + DApp architecture (TFG)

. ./.env

echo "*************************************"
echo "DApp Pet-Shop Deployment"
echo "*************************************"

# Detectar IP de minikube (NodePorts no están en localhost con minikube)
if command -v minikube &> /dev/null; then
    BESU_RPC_HOST=$(minikube ip 2>/dev/null)
    if [ -n "$BESU_RPC_HOST" ]; then
        echo "Minikube detectado. RPC host: $BESU_RPC_HOST"
        export BESU_RPC_HOST
    fi
fi

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
echo "Cleaning old dependencies..."
rm -rf node_modules package-lock.json

echo ""
echo "Installing pet-shop dependencies..."
npm install

echo ""
echo "Compiling and migrating contracts to K8s network (${BESU_RPC_HOST:-localhost}:30545)..."
truffle migrate --network sampleNetworkWallet --reset

echo ""
echo "Starting DApp on http://localhost:3001 ..."
npm run dev

