import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

task("deploy:GreeterCCIP").setAction(async function (_taskArguments: TaskArguments, { ethers }) {
  const signers = await ethers.getSigners();
  const factory = await ethers.getContractFactory("GreeterCCIP");
  const contract = await factory.connect(signers[0]).deploy();
  await contract.waitForDeployment();
  console.log("GreeterCCIP deployed to: ", await contract.getAddress());
});
