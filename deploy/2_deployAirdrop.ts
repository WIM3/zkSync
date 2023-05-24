import * as ethers from "ethers";
import * as dotenv from "dotenv";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(
    `Running deploy script for the Airdrop contract with KEY: ` + process.env.PRIVATE_KEY
  );

  //const token = await deployer.loadArtifact("ISLEToken");
  //const tokenAddress = "0x697bDe59C1dD7Bc1BC51D5789B2a6A66c404Eaf0"; // MAINNET
  const tokenAddress = "0x1e945f9f0fac4d14fa2ed865e009f6714a0aeffe"; // TESTNET

  // Initialize the wallet.  <WALLET-PRIVATE-KEY>
  const wallet = new Wallet(process.env.PRIVATE_KEY as any);

  // Create deployer object and load the artifact of the contract you want to deploy.
  console.log(`...Calling Deployer for Airdrop`);
  const deployer = new Deployer(hre, wallet);
  const airdrop = await deployer.loadArtifact("Airdrop");

  // Estimate contract deployment fee
  console.log(`...Estimating Fee`);
  const deploymentFee = await deployer.estimateDeployFee(airdrop, []);

  console.log(`...Calling Deposithandler: deployer.zkWallet.address: ` + deployer.zkWallet.address);
  console.log(`...Calling Deposithandler: utils.ETH_ADDRESS: ` + utils.ETH_ADDRESS);
  console.log(`...Calling Parsefee`);
  // Deploy this contract. The returned object will be of a `Contract` type, similarly to ones in `ethers`.
  // `greeting` is an argument for contract constructor.
  const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

  const airdropContract = await deployer.deploy(airdrop, []);

  console.log(`Deployed contract address: ` + airdropContract.address);

  // Show the contract info.
  console.log(`${airdrop.contractName} was deployed to ${airdropContract.address}`);
}
