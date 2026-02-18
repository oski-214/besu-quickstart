// Conexión directa al nodo Besu en K8s (NodePort 30545)
// Host se lee de la variable de entorno BESU_RPC_HOST (por defecto: minikube ip o localhost)
const rpcHost = process.env.BESU_RPC_HOST || "localhost";

module.exports = {
  networks: {
    sampleNetworkWallet: {
      host: rpcHost,
      port: 30545,
      network_id: "1337",
      gasPrice: 0
    }
  }
};
