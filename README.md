# zkSync

This project repo contains the files to
compile, deploy, and verify the toke on both testnet and mainnet on zkSync.

---

CONTRACTS ADDRESSES

TESTNET:

Token 0xcbd3161f5C8e39b5d0F800Dd991834F518B1c0fD
Airdrop 0xfcdF31e9C2fea705fc32304ed4908452C1fCaA8F
Vesting ---
Staking ---
TokenSale ---
NFTSale ---

MAINNET:

Token 0x7b6FA726CD564f6fEaF29F614d55a3B5dF416B7d
Airdrop 0x505b36401D34820f1cEFb0a278209B305d5b969C
Vesting ---
Staking ---
TokenSale ---
NFTSale ---

---

Token - to mint the ERC20 token
Airdrop - to Airdrop tokens to a list of "recipient addresses + amount" pairs externalized to a CVS file.

USEFUL COMMANDS

Testnet:
yarn hardhat compile

//for token complete deployemnt
yarn hardhat deploy --network zkTest

// or for a specific deploy file deployment
yarn hardhat deploy-zksync --script 1_deployISLEToken.ts --network zkTest
yarn hardhat deploy-zksync --show-stack-traces --script 2_deployAirdrop.ts --network zkTest

// to verify the token contract, sub for the right address:
yarn hardhat verify --network zkTest 0x1E945f9f0Fac4D14fa2eD865E009F6714A0AEFFE --show-stack-traces

yarn hardhat verify --network zkTest 0xBA18e8Cf4baae126c3A227f610F637B4898E4127 --show-stack-traces

Mainnet:
yarn hardhat compile

//for complete deployemnt
yarn hardhat deploy --network zkMain

// or for a specific deploy file deployment
yarn hardhat deploy-zksync --script 1_deployISLEToken.ts --network zkMain

// to verify the token contract, sub for the right address:
yarn hardhat verify --network zkMain 0x697bDe59C1dD7Bc1BC51D5789B2a6A66c404Eaf0 --show-stack-traces

other example commands:
npx hardhat run scripts/deploy.js --network ropsten

yarn hardhat run scripts/airdropTestnet.ts --network zkTest
