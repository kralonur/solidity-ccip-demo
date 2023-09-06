import fs from "fs-extra";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

task("deploy:GreeterSender").setAction(async function (_taskArguments: TaskArguments, { ethers }) {
  const signers = await ethers.getSigners();
  const factory = await ethers.getContractFactory("GreeterSender");
  const args = getContractArgs();
  const contract = await factory.connect(signers[0]).deploy(args.linkToken, args.router);
  await contract.waitForDeployment();
  console.log("GreeterSender deployed to: ", await contract.getAddress());
});

function getContractArgs() {
  const json = fs.readJSONSync("./deployargs/deployGreeterSenderArgs.json");

  const linkToken = String(json.linkToken);
  const router = String(json.router);

  return { linkToken, router };
}
