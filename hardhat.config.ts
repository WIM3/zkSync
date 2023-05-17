import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-verify";

require("dotenv").config();

module.exports = {
  zksolc: {
    version: "1.3.7",
    compilerSource: "binary",
    settings: {},
  },
  solidity: {
    version: "0.8.10",
  },

  //defaultNetwork: "zkMain",
  defaultNetwork: "zkTest",

  networks: {
    zkTest: {
      url: "https://testnet.era.zksync.dev",
      ethNetwork: "https://goerli.infura.io/" + process.env.ETHERSCAN_API_KEY || "",
      accounts: [process.env.PRIVATE_KEY],
      zksync: true,
      verifyURL: "https://zksync2-testnet-explorer.zksync.dev/contract_verification",
      gasPrice: 0,
    },
    zkMain: {
      url: "https://mainnet.era.zksync.io",
      ethNetwork: "https://mainnet.infura.io/v3/" + process.env.ETHERSCAN_API_KEY || "",
      accounts: [process.env.PRIVATE_KEY],
      zksync: true,
      verifyURL: "https://zksync2-mainnet-explorer.zksync.io/contract_verification",
    },
  },
};
