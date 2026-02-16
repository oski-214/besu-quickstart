#!/bin/bash
# Script de limpieza: elimina archivos innecesarios del quickstart
# (blockchain ahora corre en K8s, no en Docker Compose)
# Ejecutar UNA vez después de clonar el repo adaptado.

set -e
cd "$(dirname "$0")"

echo "Eliminando docker-compose de Besu (blockchain ahora en K8s)..."
rm -f docker-compose.yml \
  docker-compose_poa.yml \
  docker-compose_elk_poa.yml \
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

echo "Eliminando config de ethsigner, orion y Besu Docker..."
rm -rf config/ethsigner config/orion
rm -rf config/besu/networkFiles
rm -f config/besu/cliqueGenesis.json config/besu/ibft2GenesisPermissioning.json.template

echo "Eliminando besu Docker build (ya no se usa)..."
rm -rf besu/

echo "Eliminando permissioning-dapp..."
rm -rf permissioning-dapp

echo "Eliminando logs de orion y ELK stack..."
rm -rf logs/orion elasticsearch filebeat logstash

echo "Eliminando este script..."
rm -f cleanup.sh

echo "Limpieza completada."
