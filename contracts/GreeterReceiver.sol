// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { GreeterCCIP } from "./GreeterCCIP.sol";

/**
 * @title GreeterReceiver
 * @dev This contract consumes a CCIP message and calls the GreeterCCIP contract using message data.
 */
contract GreeterReceiver is CCIPReceiver {
    /// Address of the GreeterCCIP contract.
    GreeterCCIP public immutable greeter;

    /// Emitted when a message is received.
    event MessageReceived();

    constructor(address router, address greeterAddress) CCIPReceiver(router) {
        greeter = GreeterCCIP(greeterAddress);
    }

    /**
     * @dev Receives a CCIP message and calls the GreeterCCIP contract using message data.
     * @param message The CCIP message.
     */
    function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual override {
        (bool success, ) = address(greeter).call(message.data);
        require(success);

        emit MessageReceived();
    }
}
