import * as ethers from "ethers";
import * as dotenv from "dotenv";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import fs from "fs";

export default async function (hre: HardhatRuntimeEnvironment) {
  const wallet = new Wallet(process.env.PRIVATE_KEY as any);

  console.log(`...Calling Deployer for Airdrop`);
  const deployer = new Deployer(hre, wallet);
  const airdrop = await deployer.loadArtifact("Airdrop");

  console.log(`...Estimating Fee`);
  const deploymentFee = await deployer.estimateDeployFee(airdrop, []);

  console.log(`...deployer.zkWallet.address: ` + deployer.zkWallet.address);
  console.log(`...utils.ETH_ADDRESS: ` + utils.ETH_ADDRESS);
  const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

  const airdropContract = await deployer.deploy(airdrop, []);

  console.log(`Deployed contract address: ` + airdropContract.address);
  console.log(`${airdrop.contractName} was deployed to ${airdropContract.address}`);

  await hre.run("verify:verify", {
    address: airdropContract.address,
  });
}
