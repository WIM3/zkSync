//require("@nomiclabs/hardhat-ethers");
//import "@nomiclabs/hardhat-ethers";
import * as dotenv from "dotenv";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
const { BigNumber } = require("@ethersproject/bignumber");

async function main(hre: HardhatRuntimeEnvironment) {
  const addresses = [
    "0x457f2291324852f3963f0A99cF88A51C42A87994",
    "0xe5dce4d59cddd87630be13acaaf0cdf273bbf98d",
    "0x71647Ab44704077583BCEcD42575b9b2a7607872",
    "0xE2378b2D4f4C60f655b47f95D6a6D19a2bE28621",
    "0x474DA53C8AcC2eADeDf3584186AdDa01B065A0cF",
    "0xc059046Cf19b3a13a8E50c3398D9D1AB8E3DE900",
    "0xd2417Bf5A86f706e09bE22e293C14Dba73FdE829",
    "0x579955B31FbdbFf16a9760D5F5E869BA36431E2d",
    "0xa6688219AEaA9fc07199693Ce6075F27DE4E9Cc3",
    "0xE34c3C37D689E8e992448b70266d0CCCc4971F2f",
    "0x3953CeaA07a0fAA19Db181A6FF690D6ffCd823CA",
    "0x82C05b9a1FDB0462D1F1eD1933812C348919783E",
    "0x6918425d231dC85A28b29E8f9B7636394BAdE717",
    "0x7De27B63bd8C93775da6814e1080cF6c2556Fd1f",
    "0xC6D98b10238739d472cf185976212d8801ce2380",
  ];
  const values = [
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
    BigNumber.from("400000000000000000000"),
  ];

  //Testnet Airdrop contract address
  const contractAddress = "0x3c350E86CAf4A87310826E142411a11e05bc9509";

  console.log(`...Getting Contract: `);
  const myContract = await hre.ethers.getContractAt("Airdrop", contractAddress);
  console.log(`...Got Contract: ` + myContract.address);

  console.log(`...calling Drop Tokens`);
  const dropTokens = await myContract.dropTokens(addresses, values);

  console.log("Trx hash:", dropTokens.hash);
}

main(hre)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
