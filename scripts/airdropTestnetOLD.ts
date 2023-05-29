//require("@nomiclabs/hardhat-ethers");
//import "@nomiclabs/hardhat-ethers";
import * as dotenv from "dotenv";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { BigNumber } from "@ethersproject/bignumber";

async function main(hre: HardhatRuntimeEnvironment) {
  //Testnet Airdrop contract address
  const contractAddress = "0x969F2bF5B17C1bF1049DDf219586b6d5a3F83D91";

  const addresses = [
    "0x457f2291324852f3963f0A99cF88A51C42A87994",
    "0xe5dce4d59cddd87630be13acaaf0cdf273bbf98d",
    "0x71647Ab44704077583BCEcD42575b9b2a7607872",
    "0x7De27B63bd8C93775da6814e1080cF6c2556Fd1f",
    "0xC6D98b10238739d472cf185976212d8801ce2380",
  ];
  const values = [
    BigNumber.from("4000000000000000000"),
    BigNumber.from("4000000000000000000"),
    BigNumber.from("4000000000000000000"),
    BigNumber.from("4000000000000000000"),
    BigNumber.from("4000000000000000000"),
  ];

  const myContract = await hre.ethers.getContractAt("Airdrop", contractAddress);
  console.log(`...Got Contract: ` + myContract.address);

  console.log(`...Calling Drop Tokens`);
  const dropTokens = await myContract.dropTokens(addresses, values);
  // Wait for the transaction to be mined
  await dropTokens.wait();
  console.log("...Trx hash: ", dropTokens.hash);
  console.log("Tokens dropped successfully!");
}

main(hre)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
