#!/bin/bash
# Script de limpieza: elimina archivos innecesarios del quickstart
# (ethash, clique, privacy, permissioning, signer, orion, ethsigner)
# Ejecutar UNA vez después de clonar el repo adaptado.

set -e
cd "$(dirname "$0")"

echo "Eliminando docker-compose innecesarios..."
rm -f docker-compose.yml \
  docker-compose_elk.yml \
  docker-compose_privacy.yml \
  docker-compose_privacy_poa.yml \
  docker-compose_elk_privacy.yml \
  docker-compose_elk_privacy_poa.yml \
  docker-compose_permissioning_poa.yml \
  docker-compose_elk_permissioning_poa.yml \
  docker-compose_poa_signer.yml \
  docker-compose_elk_poa_signer.yml

echo "Eliminando scripts innecesarios..."
rm -f run-permissioning.sh run-permissioning-dapp.sh run-privacy.sh run-dapp.sh

echo "Eliminando configuración de ethsigner y orion..."
rm -rf config/ethsigner config/orion

echo "Eliminando genesis innecesarios..."
rm -f config/besu/cliqueGenesis.json config/besu/ibft2GenesisPermissioning.json.template

echo "Eliminando nodos POW (node1, node2, node3)..."
rm -rf config/besu/networkFiles/node1 config/besu/networkFiles/node2 config/besu/networkFiles/node3

echo "Eliminando permissioning-dapp..."
rm -rf permissioning-dapp

echo "Eliminando logs de orion..."
rm -rf logs/orion

echo "Eliminando este script..."
rm -f cleanup.sh

echo "✅ Limpieza completada."
