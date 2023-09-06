import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

task("verify:GreeterCCIP")
  .addParam("address", "The contract address")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    await hre.run("verify:verify", {
      address: taskArguments.address,
      constructorArguments: [],
    });
  });
