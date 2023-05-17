# zkSync

To comply, deploy, and verify the toke on both testnet and mainnet on zkSync

Testnet:
yarn hardhat compile
yarn hardhat deploy --network zkTest
yarn hardhat verify --network zkTest 0x1E945f9f0Fac4D14fa2eD865E009F6714A0AEFFE --show-stack-traces

Mainnet:
yarn hardhat compile
yarn hardhat deploy --network zkMain
yarn hardhat verify --network zkMain 0x697bDe59C1dD7Bc1BC51D5789B2a6A66c404Eaf0 --show-stack-traces

other example commands:
npx hardhat run scripts/deploy.js --network ropsten
