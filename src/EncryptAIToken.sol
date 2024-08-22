// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./DataNFT.sol";
//import "./ModelNFT.sol";

contract EncryptAIToken is ERC20, AccessControl {
    bytes32 public constant EAI_TOKEN_PROVIDER = keccak256(abi.encodePacked("EAI_TOKEN_PROVIDER"));

    mapping(address => uint256) public tokenPrices; // Mapping of accepted tokens to their prices in wei
    uint256 public baseTokenPrice; // Price for the base network token

    event TokensPurchased(address indexed purchaser, uint256 amount, address paymentToken);
    event AccessGranted(address indexed user);

    constructor(uint256 initialSupply)
        ERC20("EncryptAIToken", "EAI")
    {
        _grantRole(EAI_TOKEN_PROVIDER, address(this));
        _mint(address(this), initialSupply * 10 * decimals()); // Mint initial supply to the contract address. Allow the contract to manage the supply (good for security, ICO, staking, etc.)
    }

    function mint(address to, uint256 amount) external onlyRole(EAI_TOKEN_PROVIDER) {
        _mint(to, amount);
    }

    function setTokenPrice(uint256 price) external onlyRole(EAI_TOKEN_PROVIDER) {
        baseTokenPrice = price;
    }

    function buyTokens(address paymentToken, uint256 paymentAmount) external payable {
        uint256 amountToBuy;
        if (paymentToken == address(0)) {
            // Ether payment
            require(msg.value > 0, "You need to send some Ether to buy EAI tokens");
            require(baseTokenPrice > 0, "Base token price must be set");
            amountToBuy = msg.value / baseTokenPrice;
        } else {
            // ERC20 token payment
            uint256 tokenPrice = tokenPrices[paymentToken];
            require(tokenPrice != 0, "This payment token is not accepted");
            amountToBuy = paymentAmount / tokenPrice;
            require(
                IERC20(paymentToken).transferFrom(msg.sender, address(this), paymentAmount), "Token transfer failed"
            );
        }
        require(amountToBuy > 0, "Insufficient payment amount to buy tokens");

        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= amountToBuy, "Not enough tokens in the reserve");

        _transfer(address(this), msg.sender, amountToBuy);
        emit TokensPurchased(msg.sender, amountToBuy, paymentToken);
    }
    /*

    function withdrawEther(uint256 amount) external payable onlyDataNFTHolder {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(assetNFTHolder).transfer(amount);
    }

    function grantAccessToDataNFT(address payable dataNFTAddress, address user) public {
        DataNFT dataNFT = DataNFT(dataNFTAddress);
        require(balanceOf(user) > 0, "User does not own any EAI tokens");
        dataNFT.grantAccess(user);
        emit AccessGranted(user);
    }

    function grantAccessToModelNFT(address payable modelNFTAddress, address user) external {
        ModelNFT modelNFT = ModelNFT(modelNFTAddress);
        require(balanceOf(user) > 0, "User does not own any EAI tokens");
        modelNFT.grantAccess(user);
        emit AccessGranted(user);
    }

    receive() external payable {
        revert("Direct Ether payments not accepted");
    }
    */
}
