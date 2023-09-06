import fs from "fs-extra";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

task("verify:GreeterReceiver")
  .addParam("address", "The contract address")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const args = getContractArgs();

    await hre.run("verify:verify", {
      address: taskArguments.address,
      constructorArguments: Object.values(args),
    });
  });

function getContractArgs() {
  const json = fs.readJSONSync("./deployargs/deployGreeterReceiverArgs.json");

  const router = String(json.router);
  const greeterAddress = String(json.greeterAddress);

  return { router, greeterAddress };
}
