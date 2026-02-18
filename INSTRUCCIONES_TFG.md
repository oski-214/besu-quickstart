# Instrucciones: Red IBFT2 en Kubernetes + DApp (TFG)

## Arquitectura

```
┌──────────────────────────────────────────────────────┐
│                    KUBERNETES                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │ besu-0  │ │ besu-1  │ │ besu-2  │ │ besu-3  │   │
│  │(bootnode)│ │(valid.) │ │(valid.) │ │(valid.) │   │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘   │
│       │ NodePort 30545 (RPC)  │ NodePort 30950-53   │
│       │ NodePort 30800 (WS)   │ (metrics)           │
└───────┼───────────────────────┼─────────────────────┘
        │                       │
┌───────┼───────────────────────┼─────────────────────┐
│       ▼     DOCKER COMPOSE    ▼                      │
│  ┌──────────┐ ┌────────────┐ ┌─────────┐            │
│  │ Explorer │ │ Prometheus │ │ Grafana │            │
│  │ :25000   │ │ :9090      │ │ :3000   │            │
│  └──────────┘ └────────────┘ └─────────┘            │
└──────────────────────────────────────────────────────┘
        │
   ┌────┴─────┐
   │ Pet-shop │  (Truffle deploy manual)
   │ :3001    │
   └──────────┘
```

- **Blockchain (4 validadores IBFT2)** → corre en Kubernetes (StatefulSet con replicación)
- **DApp / Monitorización** → corre en Docker Compose, conectada a K8s vía NodePort

---

## Requisitos previos

- **Docker** (v20+) + **Docker Compose V2** (plugin):
  ```bash
  sudo apt-get update && sudo apt-get install docker-compose-plugin
  docker compose version   # debe mostrar v2.x
  ```
- **kubectl** configurado y conectado a tu cluster K8s:
  ```bash
  kubectl version --client
  kubectl cluster-info    # debe poder conectar
  ```
- **Node.js** + **Truffle** (solo para desplegar la DApp pet-shop):
  ```bash
  # Configurar npm global sin sudo (una sola vez)
  mkdir -p ~/.npm-global
  npm config set prefix '~/.npm-global'
  echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
  source ~/.bashrc

  # Instalar Truffle
  npm install -g truffle
  ```
- Linux (probado en Ubuntu)

---

## 1. Clonar el repo

```bash
cd ~
git clone https://github.com/oski-214/besu-quickstart.git
cd besu-quickstart
```

---

## 2. Configurar las keys de nodo

Edita `KEYS_PATH` en el fichero `.env` para que apunte a tu directorio de keys:

```bash
# En .env, actualiza esta línea:
KEYS_PATH=/home/oscar-214/Documents/BESU/besu-25.9.0/bin/IBFT-NW/keys
```

Luego crea los secretos de Kubernetes:

```bash
chmod +x create-secrets.sh
./create-secrets.sh
```

Esto creará los secretos `besu-node-key-0` a `besu-node-key-3` en el namespace `tfg`.

---

## 3. Arrancar todo

Un solo comando despliega la blockchain en K8s y la DApp infrastructure en Docker:

```bash
chmod +x run.sh stop.sh resume.sh remove.sh list.sh
./run.sh
```

El script hace automáticamente:
1. `kubectl apply` de namespace, ConfigMap, HeadLess Service, StatefulSet, RPC Services, NodePort Services
2. Espera a que los 4 pods besu estén ready
3. `docker compose up` del explorer, Prometheus y Grafana

---

## 4. Desplegar la DApp pet-shop

Una vez la red esté corriendo (puedes verificar con `./list.sh`):

```bash
# Opción A: Script automático (instala truffle si falta, compila, despliega y arranca)
chmod +x run-dapp.sh
./run-dapp.sh

# Opción B: Manual
cd pet-shop
npm install
truffle migrate --network sampleNetworkWallet --reset
npm run dev
cd ..
```

La DApp estará en `http://localhost:3001`.

---

## 5. Configurar MetaMask

> **Nota minikube:** Si usas minikube, reemplaza `localhost` por la IP de minikube:
> ```bash
> minikube ip   # ej: 192.168.49.2
> ```

1. **Añadir red manualmente:**
   - **RPC URL:** `http://<minikube-ip>:30545` (o `http://localhost:30545` si usas K8s nativo)
   - **Chain ID:** `1337`
   - **Símbolo:** `ETH`

2. **Importar cuenta con fondos:**
   - Private key: `c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3`
   - (Cuenta `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` — 90000 ETH en el genesis)

3. Abrir `http://localhost:3001` → Adoptar un pet → Confirmar en MetaMask

---

## 6. Puertos y servicios

| Puerto | Servicio | Tipo | URL |
|--------|----------|------|-----|
| 30545 | RPC JSON-HTTP (besu-0) | K8s NodePort | `http://localhost:30545` |
| 30800 | RPC WebSocket (besu-0) | K8s NodePort | `ws://localhost:30800` |
| 25000 | Block Explorer | Docker | `http://localhost:25000` |
| 3000 | Grafana (dashboards) | Docker | `http://localhost:3000` |
| 9090 | Prometheus (métricas) | Docker | `http://localhost:9090` |
| 3001 | DApp pet-shop | Local/npm | `http://localhost:3001` |
| 30950-30953 | Metrics (besu-0 a besu-3) | K8s NodePort | (interno para Prometheus) |

---

## 7. Comandos de gestión

```bash
./run.sh       # Desplegar todo (K8s + Docker Compose)
./stop.sh      # Parar todo (scale K8s a 0 + stop Docker Compose)
./resume.sh    # Reanudar (scale K8s a 4 + start Docker Compose)
./remove.sh    # Eliminar todo (delete K8s resources + remove Docker)
./list.sh      # Ver estado de pods y endpoints
```

### Comandos útiles de kubectl

```bash
# Ver pods
kubectl get pods -n tfg -o wide

# Ver logs de un nodo
kubectl logs -n tfg besu-0 --tail=50 -f

# Ver servicios
kubectl get svc -n tfg

# Describir un pod
kubectl describe pod besu-0 -n tfg
```

---

## 8. Configuración de la blockchain

- **Consenso:** IBFT2
- **Chain ID:** 1337
- **Block period:** 2 segundos
- **Epoch length:** 30000
- **Request timeout:** 4 segundos
- **Gas limit:** 0x47b760
- **Nodos:** 4 validadores (StatefulSet con réplicas=4)
- **Resiliencia:** Si un pod se cae, K8s lo recrea automáticamente

### Cuentas pre-funded en el genesis

| Dirección | Private Key | Balance |
|-----------|-------------|---------|
| `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73` | `8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` | 200 ETH |
| `0x627306090abaB3A6e1400e9345bC60c78a8BEf57` | `c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` | 90000 ETH |
| `0xf17f52151EbEF6C7334FAD080c5704D77216b732` | `ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f` | 90000 ETH |

---

## 9. Estructura del proyecto

```
besu-quickstart/
├── run.sh / stop.sh / resume.sh / remove.sh / list.sh   # Gestión del ciclo de vida
├── create-secrets.sh                                      # Crear secretos K8s
├── docker-compose_dapp.yml                                # Explorer + Prometheus + Grafana
├── .env                                                   # Variables (KEYS_PATH, K8S_NAMESPACE...)
├── TFG_INFO_Blockchain/KUBERNETES/
│   ├── namespace.yaml                                     # Namespace tfg
│   ├── ConfigMap.yaml                                     # Genesis block (chainId 1337)
│   ├── HeadLess_Service.yaml                              # P2P discovery entre pods
│   ├── StatefulSet.yaml                                   # 4 validadores Besu (con métricas)
│   ├── RPC_Service.yaml                                   # ClusterIP RPC por pod
│   ├── ExternalAccess_Service.yaml                        # NodePort para RPC + métricas
│   └── Secretos.txt                                       # Referencia de comandos manuales
├── block-explorer-light/                                  # Block Explorer (nginx → K8s NodePort)
├── monitoring/
│   ├── prometheus/prometheus.yml                          # Targets: K8s NodePorts 30950-30953
│   └── grafana/provisioning/                              # Dashboards Besu
└── pet-shop/                                              # DApp + Smart contract Adoption.sol
```
