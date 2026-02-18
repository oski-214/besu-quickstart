#!/bin/bash -u

# Copyright 2018 ConsenSys AG.
# Modified for K8s + DApp architecture (TFG)

. ./.env

# Verificaciones básicas (sin lock file — la DApp no gestiona la red)
hash truffle 2>/dev/null || NEED_TRUFFLE=true

echo "*************************************"
echo "DApp Pet-Shop Deployment"
echo "*************************************"

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
echo "Compiling and migrating contracts to K8s network (port 30545)..."
truffle migrate --network sampleNetworkWallet --reset

echo ""
echo "Starting DApp on http://localhost:3001 ..."
npm run dev

