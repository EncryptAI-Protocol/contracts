// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Consumer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ConsumerFactory {
    event ConsumerDeployed(address indexed consumerAddress, address indexed owner);

    function createConsumer(
        address payable sublicenseTokenAddress,
        address payable dataNFTAddress,
        address payable modelNFTAddress,
        uint256 feePercentage
    ) external returns (address) {
        Consumer newConsumer = new Consumer(sublicenseTokenAddress, dataNFTAddress, modelNFTAddress, feePercentage);
        emit ConsumerDeployed(address(newConsumer), msg.sender);
        return address(newConsumer);
    }
}
