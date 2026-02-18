// Conexión directa al nodo Besu en K8s (NodePort 30545)
// No usa hdwallet-provider para evitar errores de compilación de scrypt
module.exports = {
  networks: {
    sampleNetworkWallet: {
      host: "localhost",
      port: 30545,
      network_id: "1337",
      gasPrice: 0
    }
  }
};
