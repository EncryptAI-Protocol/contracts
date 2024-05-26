// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SublicenseToken.sol";
import "./DataNFT.sol";
import "./ModelNFT.sol";

contract Consumer is Ownable {
    SublicenseToken public sublicenseToken;
    DataNFT public dataNFT;
    ModelNFT public modelNFT;
    uint256 public feePercentage; // Fee percentage in basis points (e.g., 100 = 1%)

    event TokensPurchased(address indexed purchaser, uint256 amount, address paymentToken);
    event DataUsagePaid(address indexed payer, uint256 amount);
    event AccessGranted(address indexed user);
    event FeePaid(address indexed payer, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);

    constructor(
        address payable sublicenseTokenAddress,
        address payable dataNFTAddress,
        address payable modelNFTAddress,
        uint256 _feePercentage
    ) Ownable(msg.sender) {
        sublicenseToken = SublicenseToken(sublicenseTokenAddress);
        dataNFT = DataNFT(dataNFTAddress);
        modelNFT = ModelNFT(modelNFTAddress);
        feePercentage = _feePercentage;
    }

    function buyTokens(address paymentToken, uint256 paymentAmount) public payable {
        sublicenseToken.buyTokens{value: msg.value}(paymentToken, paymentAmount);
        emit TokensPurchased(msg.sender, paymentAmount, paymentToken);
    }

    function payForModelUsage() public payable {
        uint256 fee = (msg.value * feePercentage) / 10000;
        uint256 amountAfterFee = msg.value - fee;
        (bool successModel,) = payable(address(modelNFT)).call{value: amountAfterFee}("");
        require(successModel, "Payment to ModelNFT failed");

        (bool successData,) = payable(address(dataNFT)).call{value: fee}("");
        require(successData, "Fee payment to DataNFT failed");

        emit DataUsagePaid(msg.sender, msg.value);
        emit FeePaid(msg.sender, fee);
    }

    function grantAccessToDataNFT(address user) public {
        require(sublicenseToken.balanceOf(user) > 0, "User does not own any sublicense tokens");
        sublicenseToken.grantAccessToDataNFT(payable(address(dataNFT)), user);
        emit AccessGranted(user);
    }

    function grantAccessToModelNFT(address user) public {
        require(sublicenseToken.balanceOf(user) > 0, "User does not own any sublicense tokens");
        sublicenseToken.grantAccessToModelNFT(payable(address(modelNFT)), user);
        emit AccessGranted(user);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Withdrawal failed");

        emit Withdraw(msg.sender, balance);
    }

    // Function to receive Ether directly
    receive() external payable {}
}
