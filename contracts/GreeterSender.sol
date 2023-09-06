// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IGreeterReceiver } from "./IGreeterReceiver.sol";

contract GreeterSender is Ownable {
    enum Fee {
        NATIVE,
        LINK
    }

    IRouterClient public immutable router;
    IERC20 public immutable linkToken;

    event MessageSent(bytes32 messageId);

    constructor(address _linkToken, address _router) {
        linkToken = IERC20(_linkToken);
        router = IRouterClient(_router);

        linkToken.approve(_router, type(uint256).max);
    }

    receive() external payable {}

    function transferNative() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function transferLink() external onlyOwner {
        linkToken.transfer(msg.sender, linkToken.balanceOf(address(this)));
    }

    function setGreetingNative(
        uint64 destinationChainSelector,
        address receiver,
        string calldata greetingMessage
    ) external onlyOwner {
        Client.EVM2AnyMessage memory message = getCCIPMessage(receiver, greetingMessage, Fee.NATIVE);

        uint256 fee = getFeePublic(destinationChainSelector, message);

        bytes32 messageId = router.ccipSend{ value: fee }(destinationChainSelector, message);

        emit MessageSent(messageId);
    }

    function setGreetingLink(
        uint64 destinationChainSelector,
        address receiver,
        string calldata greetingMessage
    ) external onlyOwner {
        Client.EVM2AnyMessage memory message = getCCIPMessage(receiver, greetingMessage, Fee.LINK);

        bytes32 messageId = router.ccipSend(destinationChainSelector, message);

        emit MessageSent(messageId);
    }

    function getFeeExternal(
        uint64 destinationChainSelector,
        address receiver,
        string calldata greetingMessage,
        Fee feePayment
    ) external view returns (uint256) {
        Client.EVM2AnyMessage memory message = getCCIPMessage(receiver, greetingMessage, feePayment);

        return getFeePublic(destinationChainSelector, message);
    }

    function getCCIPMessage(
        address receiver,
        string calldata greetingMessage,
        Fee feePayment
    ) public view returns (Client.EVM2AnyMessage memory) {
        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(receiver),
                data: abi.encodeWithSelector(IGreeterReceiver.setGreeting.selector, greetingMessage),
                tokenAmounts: new Client.EVMTokenAmount[](0),
                extraArgs: "",
                feeToken: feePayment == Fee.LINK ? address(linkToken) : address(0)
            });
    }

    function getFeePublic(
        uint64 destinationChainSelector,
        Client.EVM2AnyMessage memory message
    ) public view returns (uint256) {
        return router.getFee(destinationChainSelector, message);
    }
}
