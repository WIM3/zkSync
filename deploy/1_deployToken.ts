import * as ethers from "ethers";
import * as dotenv from "dotenv";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

export default async function (hre: HardhatRuntimeEnvironment) {
  const name = "GALL v1.0";
  const symbol = "GALL";

  const wallet = new Wallet(process.env.PRIVATE_KEY as any);
  console.log(`...Initialized Wallet`);

  const deployer = new Deployer(hre, wallet);
  const artifact = await deployer.loadArtifact("Token");
  console.log(`...Calling Deployer & Artifact for token`);

  const deploymentFee = await deployer.estimateDeployFee(artifact, [name, symbol]);
  console.log(`...Estimated Fee`);

  const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
  console.log(`...Estimated cost of deployment: ${parsedFee} ETH`);

  const tokenContract = await deployer.deploy(artifact, [name, symbol]);
  console.log(`...Deployed contract`);

  console.log(`${artifact.contractName} was deployed to ${tokenContract.address}`);

  await hre.run("verify:verify", {
    address: tokenContract.address,
    constructorArguments: [name, symbol],
  });
}
