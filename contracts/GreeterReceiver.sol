// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { GreeterCCIP } from "./GreeterCCIP.sol";

contract GreeterReceiver is CCIPReceiver {
    GreeterCCIP public immutable greeter;

    event MessageReceived();

    constructor(address router, address greeterAddress) CCIPReceiver(router) {
        greeter = GreeterCCIP(greeterAddress);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual override {
        (bool success, ) = address(greeter).call(message.data);
        require(success);

        emit MessageReceived();
    }
}
