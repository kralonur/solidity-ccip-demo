// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

interface IGreeterReceiver {
    function setGreeting(string calldata greetingMessage) external;
}
