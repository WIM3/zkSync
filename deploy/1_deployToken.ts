import * as ethers from "ethers";
import * as dotenv from "dotenv";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script for the Token contract with KEY: ` + process.env.PRIVATE_KEY);

  const wallet = new Wallet(process.env.PRIVATE_KEY as any);

  console.log(`...Calling Deployer for token`);

  const deployer = new Deployer(hre, wallet);
  const artifact = await deployer.loadArtifact("Token");

  console.log(`...Estimating Fee`);

  const deploymentFee = await deployer.estimateDeployFee(artifact, []);

  console.log(`...Calling Deposithandler: deployer.zkWallet.address: ` + deployer.zkWallet.address);
  console.log(`...Calling Deposithandler: utils.ETH_ADDRESS: ` + utils.ETH_ADDRESS);

  const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

  const tokenContract = await deployer.deploy(artifact);

  console.log("constructor args:" + tokenContract.interface.encodeDeploy([]));

  const contractAddress = tokenContract.address;
  console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
}
