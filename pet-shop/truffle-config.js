const HDWalletProvider = require("@truffle/hdwallet-provider");

// Cuenta con 90000 ETH en el genesis
const privateKey = "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3";
const rpcUrl = "http://localhost:30545";

module.exports = {
  networks: {
    sampleNetworkWallet: {
      provider: () => new HDWalletProvider(privateKey, rpcUrl),
      network_id: "1337",
      gasPrice: 0
    }
  }
};
