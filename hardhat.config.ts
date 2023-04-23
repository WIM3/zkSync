import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-verify";

require("dotenv").config();

module.exports = {
  zksolc: {
    version: "1.3.8",
    compilerSource: "binary",
    settings: {},
  },
  //defaultNetwork: "zkSyncTestnet",
  defaultNetwork: "zkSyncMainnet",

  networks: {
    zkSyncTestnet: {
      url: "https://testnet.era.zksync.dev",
      ethNetwork: "https://goerli.infura.io/" + process.env.ETHERSCAN_API_KEY || "",
      accounts: [process.env.PRIVATE_KEY],
      zksync: true,
      verifyURL: "https://explorer.zksync.io/",
      gasPrice: 0,
    },
    zkSyncMainnet: {
      url: "https://mainnet.era.zksync.io",
      ethNetwork: "https://mainnet.infura.io/v3/" + process.env.ETHERSCAN_API_KEY || "",
      accounts: [process.env.PRIVATE_KEY],
      gasPrice: 0,
      zksync: true,
    },
  },
  solidity: {
    version: "0.8.8",
  },
};
