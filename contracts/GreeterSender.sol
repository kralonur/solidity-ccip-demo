// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IGreeterReceiver } from "./IGreeterReceiver.sol";

/**
 * @title GreeterSender
 * @dev This contract sends a greeting message to a GreeterReceiver contract using CCIP.
 */
contract GreeterSender is Ownable {
    enum Fee {
        NATIVE,
        LINK
    }

    /// Address of the CCIP router.
    IRouterClient public immutable router;
    /// Address of the LINK token.
    IERC20 public immutable linkToken;

    /**
     * @dev Emitted when a CCIP message is sent.
     * @param messageId The ID of the message.
     */
    event MessageSent(bytes32 messageId);

    constructor(address _linkToken, address _router) {
        linkToken = IERC20(_linkToken);
        router = IRouterClient(_router);

        linkToken.approve(_router, type(uint256).max);
    }

    /**
     * @dev Fallback function to receive native tokens.
     * It is required to send pay for CCIP fees in native tokens.
     */
    receive() external payable {}

    /**
     * @dev Transfers native tokens to the owner.
     */
    function transferNative() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @dev Transfers LINK tokens to the owner.
     */
    function transferLink() external onlyOwner {
        linkToken.transfer(msg.sender, linkToken.balanceOf(address(this)));
    }

    /**
     * @dev Sends a greeting message to a GreeterReceiver contract using CCIP with native fees.
     * @param destinationChainSelector The chain selector of the destination chain.
     * @param receiver The address of the GreeterReceiver contract.
     * @param greetingMessage The greeting message to send.
     */
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

    /**
     * @dev Sends a greeting message to a GreeterReceiver contract using CCIP with LINK token.
     * @param destinationChainSelector The chain selector of the destination chain.
     * @param receiver The address of the GreeterReceiver contract.
     * @param greetingMessage The greeting message to send.
     */
    function setGreetingLink(
        uint64 destinationChainSelector,
        address receiver,
        string calldata greetingMessage
    ) external onlyOwner {
        Client.EVM2AnyMessage memory message = getCCIPMessage(receiver, greetingMessage, Fee.LINK);

        bytes32 messageId = router.ccipSend(destinationChainSelector, message);

        emit MessageSent(messageId);
    }

    /**
     * @dev Gets the fee for sending a greeting message to a GreeterReceiver contract using CCIP.
     * @param destinationChainSelector The chain selector of the destination chain.
     * @param receiver The address of the GreeterReceiver contract.
     * @param greetingMessage The greeting message to send.
     */
    function getFeeExternal(
        uint64 destinationChainSelector,
        address receiver,
        string calldata greetingMessage,
        Fee feePayment
    ) external view returns (uint256) {
        Client.EVM2AnyMessage memory message = getCCIPMessage(receiver, greetingMessage, feePayment);

        return getFeePublic(destinationChainSelector, message);
    }

    /**
     * @dev Gets the CCIP message.
     * @param receiver The address of the GreeterReceiver contract.
     * @param greetingMessage The greeting message to send.
     * @param feePayment The fee payment method.
     */
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

    /**
     * @dev Gets the fee for sending a CCIP message.
     * @param destinationChainSelector The chain selector of the destination chain.
     * @param message The CCIP message.
     */
    function getFeePublic(
        uint64 destinationChainSelector,
        Client.EVM2AnyMessage memory message
    ) public view returns (uint256) {
        return router.getFee(destinationChainSelector, message);
    }
}
