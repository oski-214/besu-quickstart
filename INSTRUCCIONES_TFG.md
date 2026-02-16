# Instrucciones para ejecutar la red IBFT2 con el quickstart

## Requisitos previos

- **Docker** (v20+): https://docs.docker.com/engine/install/
- **Docker Compose V2** (plugin): los scripts usan `docker compose` (con espacio, no guión).
  ```bash
  # Instalar el plugin Docker Compose V2 en Ubuntu/Debian:
  sudo apt-get update
  sudo apt-get install docker-compose-plugin
  
  # Verificar:
  docker compose version
  # Debe mostrar: Docker Compose version v2.x.x
  ```
  > **Nota:** Si tienes instalado `docker-compose` 1.x (el antiguo basado en Python), NO funcionará con Python 3.12+. Usa el plugin V2 en su lugar.
- [Node.js](https://nodejs.org/en/download/) y [Truffle](https://www.trufflesuite.com/truffle) (solo para la DApp)
- Linux (probado en Ubuntu)

---

## 1. Clonar el repo

```bash
cd ~
git clone <URL_DE_TU_FORK_O_REPO>
cd besu-quickstart
```

---

## 2. Copiar tus keys de nodo

Cada nodo necesita su fichero `key` (clave privada). Tus keys están en:
```
/home/oscar-214/Documents/BESU/besu-25.9.0/bin/IBFT-NW/keys/
```

Cópialas así:

```bash
# Node-1 → bootnode (es el primer validador y nodo de arranque)
cp /home/oscar-214/Documents/BESU/besu-25.9.0/bin/IBFT-NW/keys/Node-1-KEY/key \
   /home/oscar-214/Documents/DAPP/besu-quickstart/config/besu/networkFiles/bootnode/keys/key

# Node-2 → validator2
cp /home/oscar-214/Documents/BESU/besu-25.9.0/bin/IBFT-NW/keys/Node-2-KEY/key \
   /home/oscar-214/Documents/DAPP/besu-quickstart/config/besu/networkFiles/validator2/keys/key

# Node-3 → validator3
cp /home/oscar-214/Documents/BESU/besu-25.9.0/bin/IBFT-NW/keys/Node-3-KEY/key \
   /home/oscar-214/Documents/DAPP/besu-quickstart/config/besu/networkFiles/validator3/keys/key

# Node-4 → validator4
cp /home/oscar-214/Documents/BESU/besu-25.9.0/bin/IBFT-NW/keys/Node-4-KEY/key \
   /home/oscar-214/Documents/DAPP/besu-quickstart/config/besu/networkFiles/validator4/keys/key

# rpcnode → puedes usar Node-1 (no valida, solo expone RPC)
cp /home/oscar-214/Documents/BESU/besu-25.9.0/bin/IBFT-NW/keys/Node-1-KEY/key \
   /home/oscar-214/Documents/DAPP/besu-quickstart/config/besu/networkFiles/rpcnode/keys/key
```

> **Nota:** Los ficheros `key.pub` no hace falta copiarlos. El bootnode genera su pubkey automáticamente al arrancar.

### Mapeo de nodos

| Tu nodo (Kubernetes) | Carpeta en el quickstart | Rol |
|---|---|---|
| Node-1 (besu-0) | `networkFiles/bootnode/keys/` | Validador 1 + Bootnode |
| Node-2 (besu-1) | `networkFiles/validator2/keys/` | Validador 2 |
| Node-3 (besu-2) | `networkFiles/validator3/keys/` | Validador 3 |
| Node-4 (besu-3) | `networkFiles/validator4/keys/` | Validador 4 |
| — | `networkFiles/rpcnode/keys/` | Nodo RPC (no valida) |

---

## 3. Limpieza inicial (solo la primera vez)

Eliminar archivos innecesarios (ethash, clique, privacy, permissioning, orion...):

```bash
chmod +x cleanup.sh
./cleanup.sh
```

---

## 4. Arrancar la red

```bash
# Red IBFT2 + Block Explorer + Prometheus + Grafana
./run.sh

# Con ELK (Elasticsearch/Logstash/Kibana) para logs centralizados
./run.sh -e
```

---

## 5. Desplegar la DApp pet-shop (puerto 3001)

La DApp se despliega automáticamente como servicio Docker en `docker-compose_poa.yml`.
Si necesitas redesplegar el smart contract manualmente:

```bash
# Instalar Truffle si no lo tienes
npm install -g truffle

cd pet-shop
truffle migrate --network sampleNetworkWallet
cd ..
```

---

## 6. Configurar MetaMask

1. Abrir MetaMask → **Añadir red manualmente**:
   - **RPC URL:** `http://localhost:8550`
   - **Chain ID:** `1337`
   - **Símbolo:** `ETH`

2. Importar cuenta con fondos:
   - `My Accounts` → `Import Account`
   - Private key: `c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3`
   - (Corresponde a la cuenta `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` del genesis)

3. Abrir `http://localhost:3001` → Adoptar un pet → Confirmar transacción en MetaMask

---

## 7. Puertos y servicios

| Puerto | Servicio | URL |
|--------|----------|-----|
| 8545 | RPC JSON (MetaMask, Truffle) | `http://localhost:8550` |
| 3001 | DApp pet-shop | `http://localhost:3001` |
| 25000 | Block Explorer | `http://localhost:25000` |
| 3000 | Grafana (dashboards) | `http://localhost:3000` |
| 9090 | Prometheus (métricas) | `http://localhost:9090` |
| 5601 | Kibana (solo con `-e`) | `http://localhost:5601` |

---

## 8. Comandos útiles

```bash
./stop.sh      # Parar la red (sin borrar datos)
./resume.sh    # Reanudar la red parada
./remove.sh    # Eliminar todo (containers + volúmenes + imágenes)
./list.sh      # Listar servicios y endpoints activos
```

---

## 9. Configuración de la blockchain

- **Consenso:** IBFT2
- **Chain ID:** 1337
- **Block period:** 2 segundos
- **Epoch length:** 30000
- **Request timeout:** 4 segundos
- **Gas limit:** 0x47b760
- **Genesis:** `config/besu/ibft2Genesis.json`
- **Config nodos:** `config/besu/config.toml`

### Cuentas pre-funded en el genesis

| Dirección | Private Key | Balance |
|-----------|-------------|---------|
| `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73` | `8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` | 200 ETH |
| `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` | `c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` | 90000 ETH |
| `0xf17f52151EbEF6C7334FAD080c5704D77216b732` | `ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f` | 90000 ETH |

---

## 10. Estructura de archivos clave

```
besu-quickstart/
├── run.sh                          # Arrancar red (solo -e como opción)
├── stop.sh / resume.sh / remove.sh # Gestión del ciclo de vida
├── docker-compose_poa.yml          # Red IBFT2 base
├── docker-compose_elk_poa.yml      # Red IBFT2 + ELK
├── .env                            # Variables de entorno (BESU_VERSION, etc.)
├── config/besu/
│   ├── ibft2Genesis.json           # ← TU genesis (chainId 1337, tus validadores)
│   ├── config.toml                 # Configuración RPC/WS/GraphQL/Metrics
│   └── networkFiles/
│       ├── bootnode/keys/key       # ← TU Node-1 key
│       ├── validator2/keys/key     # ← TU Node-2 key
│       ├── validator3/keys/key     # ← TU Node-3 key
│       ├── validator4/keys/key     # ← TU Node-4 key
│       └── rpcnode/keys/key        # ← Key del nodo RPC
├── pet-shop/                       # DApp + Smart contract Adoption.sol
├── monitoring/                     # Prometheus + Grafana config
├── elasticsearch/ filebeat/ logstash/  # ELK stack config
└── block-explorer-light/           # Block Explorer
```
