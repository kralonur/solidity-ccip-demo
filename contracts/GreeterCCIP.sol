// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IGreeterReceiver } from "./IGreeterReceiver.sol";

/**
 * @title GreeterCCIP
 * @dev This contract sets and retrieves a greeting message.
 */
contract GreeterCCIP is IGreeterReceiver {
    /// The current greeting message.
    string public greeting;

    /**
     * @dev Emitted when a new greeting message is received.
     * @param greetingMessage  The new greeting message.
     * @param sender The sender of the greeting message (function caller).
     */
    event GreetingReceived(string greetingMessage, address sender);

    /**
     * @dev Sets the greeting message.
     * @param greetingMessage The greeting message to set.
     */
    function setGreeting(string calldata greetingMessage) external override {
        greeting = greetingMessage;

        emit GreetingReceived(greetingMessage, msg.sender);
    }
}
