import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-verify";
import "@nomiclabs/hardhat-ethers";

require("dotenv").config();

module.exports = {
  hardhat: {
    // Other Hardhat options...

    logging: {
      level: "debug", // Set the log level to "debug" or "info"
    },
  },
  zksolc: {
    version: "1.3.7",
    compilerSource: "binary",
    settings: {},
  },
  solidity: {
    version: "0.8.10",
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },

  //defaultNetwork: "zkMain",
  defaultNetwork: "zkTest",

  networks: {
    hardhat: {},
    zkTest: {
      url: "https://testnet.era.zksync.dev",
      ethNetwork: "https://goerli.infura.io/" + process.env.ETHERSCAN_API_KEY || "",
      accounts: [process.env.PRIVATE_KEY],
      zksync: true,
      gas: 2100000,
      gasPrice: 250000000,
      verifyURL: "https://zksync2-testnet-explorer.zksync.dev/contract_verification",
    },
    zkMain: {
      url: "https://mainnet.era.zksync.io",
      ethNetwork: "https://mainnet.infura.io/v3/" + process.env.ETHERSCAN_API_KEY || "",
      accounts: [process.env.PRIVATE_KEY],
      zksync: true,
      gas: 2100000,
      gasPrice: 250000000,
      verifyURL: "https://zksync2-mainnet-explorer.zksync.io/contract_verification",
    },
  },
};
