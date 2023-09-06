// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IGreeterReceiver } from "./IGreeterReceiver.sol";

contract GreeterCCIP is IGreeterReceiver {
    string public greeting;

    event GreetingReceived(string greetingMessage, address sender);

    function setGreeting(string calldata greetingMessage) external override {
        greeting = greetingMessage;

        emit GreetingReceived(greetingMessage, msg.sender);
    }
}
