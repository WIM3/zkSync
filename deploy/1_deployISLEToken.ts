import * as ethers from "ethers";
import * as dotenv from "dotenv";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(
    `Running deploy script for the ISLE Token contract with KEY: ` + process.env.PRIVATE_KEY
  );

  // Initialize the wallet.  <WALLET-PRIVATE-KEY>
  const wallet = new Wallet(process.env.PRIVATE_KEY as any);

  console.log(`...Calling Deployer`);

  // Create deployer object and load the artifact of the contract you want to deploy.
  const deployer = new Deployer(hre, wallet);
  //const artifact1 = await deployer.loadArtifact("Greeter");
  const artifact = await deployer.loadArtifact("ISLEToken");

  console.log(`...Estimating Fee`);
  // Estimate contract deployment fee
  //const greeting = "Hi there!";
  const deploymentFee = await deployer.estimateDeployFee(artifact, []);

  console.log(`...Calling Deposithandler`);
  // OPTIONAL: Deposit funds to L2
  // Comment this block if you already have funds on zkSync.

  console.log(`...Calling Deposithandler: deployer.zkWallet.address: ` + deployer.zkWallet.address);
  console.log(`...Calling Deposithandler: utils.ETH_ADDRESS: ` + utils.ETH_ADDRESS);
  /*
  const depositHandle = await deployer.zkWallet.deposit({
    to: deployer.zkWallet.address,
    token: utils.ETH_ADDRESS,
    amount: deploymentFee.mul(2),
  });
  // Wait until the deposit is processed on zkSync
  await depositHandle.wait();
*/
  console.log(`...Calling Parsefee`);
  // Deploy this contract. The returned object will be of a `Contract` type, similarly to ones in `ethers`.
  // `greeting` is an argument for contract constructor.
  const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

  const tokenContract = await deployer.deploy(artifact);

  //obtain the Constructor Arguments
  console.log("constructor args:" + tokenContract.interface.encodeDeploy([]));

  // Show the contract info.
  const contractAddress = tokenContract.address;
  console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
}
