# zkSync

This project repo contains the files to
compile, deploy, and verify the toke on both testnet and mainnet on zkSync.

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

CONTRACTS ADDRESSES

TestNet
ISLE Token 0x1E945f9f0Fac4D14fa2eD865E009F6714A0AEFFE
Airdrop 0x3c350E86CAf4A87310826E142411a11e05bc9509
Vesting ---

MainNet
ISLE Token 0x697bDe59C1dD7Bc1BC51D5789B2a6A66c404Eaf0
Airdrop 0xD32b58fA2ccE559921b49B85Bd2C73E6B474c981
Vesting ---
