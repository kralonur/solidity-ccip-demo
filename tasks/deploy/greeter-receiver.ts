import fs from "fs-extra";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

task("deploy:GreeterReceiver").setAction(async function (_taskArguments: TaskArguments, { ethers }) {
  const signers = await ethers.getSigners();
  const factory = await ethers.getContractFactory("GreeterReceiver");
  const args = getContractArgs();
  const contract = await factory.connect(signers[0]).deploy(args.router, args.greeterAddress);
  await contract.waitForDeployment();
  console.log("GreeterReceiver deployed to: ", await contract.getAddress());
});

function getContractArgs() {
  const json = fs.readJSONSync("./deployargs/deployGreeterReceiverArgs.json");

  const router = String(json.router);
  const greeterAddress = String(json.greeterAddress);

  return { router, greeterAddress };
}
