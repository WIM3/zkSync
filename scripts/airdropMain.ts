// Import the required libraries
import { HardhatRuntimeEnvironment } from "hardhat/types";
import fs from "fs";
import csv from "csv-parser";
const { BigNumber } = require("@ethersproject/bignumber");
import { Wallet, utils } from "zksync-web3";

async function main(hre: HardhatRuntimeEnvironment) {
  const airdropAddress = "0x505b36401D34820f1cEFb0a278209B305d5b969C"; // AIRDROP TESTNET
  const tokenAddress = "0x7b6FA726CD564f6fEaF29F614d55a3B5dF416B7d"; // TOKEN TESTNET

  // Define the CSV file name and format
  const csvFileName = "./airdrop/testnet.csv"; // Replace with the actual file name
  const csvFormat = {
    // Replace with the actual format
    headers: ["recipient", "amount"],
    delimiter: ",",
    skipLines: 1,
  };

  // Create arrays to store the recipients and amounts
  let recipients: string[] = [];
  let amounts: (typeof BigNumber)[] = []; // Change to BigNumber array

  // Read the CSV file and parse it
  fs.createReadStream(csvFileName)
    .pipe(csv(csvFormat))
    .on("data", (data) => {
      console.log("address: " + data.recipient + "  amount: " + data.amount);
      recipients.push(data.recipient);
      amounts.push(BigNumber.from(data.amount)); // Convert string to BigNumber with base 10
    })
    .on("end", async () => {
      const [deployer] = await hre.ethers.getSigners();
      // Load the Airdrop contract instance
      const airdropArtifact = await hre.artifacts.readArtifact("Airdrop");
      const airdrop = new hre.ethers.Contract(airdropAddress, airdropArtifact.abi, deployer);

      // Get a contract instance using HRE
      //const contract = await hre.ethers.getContractAt(contractName, contractAddress);
      console.log(`...Got Airdrop Contract: ` + airdrop.address);
      //console.log(`...Got Airdrop Tooken Balance: ` + airdrop.balanceOf(tokenAddress));
      //console.log(`...Got Airdrop  ETH   Balance: ` + airdrop.balance);
      console.log(`...Got Token Contract: ` + tokenAddress);

      // Call the dropTokens function with the arrays
      try {
        //let gasEstimate = await airdrop.estimateGas.dropTokens(recipients, amounts);
        //console.log(">>>> Gas estimate:", gasEstimate.toString());
        const feeData = await hre.ethers.provider.getFeeData();
        console.log("feeData:", feeData);
        let tk = await airdrop.setTokenAddress(tokenAddress);
        let tx = await airdrop.dropTokens(recipients, amounts);
        console.log("Transaction sent:", tx.hash);
        await tx.wait();
        console.log("Transaction confirmed:", tx.hash);
      } catch (error) {
        console.error("Transaction failed:", error.message);
      }
    });
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
