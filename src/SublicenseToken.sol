// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./DataNFT.sol";
import "./ModelNFT.sol";

contract SublicenseToken is ERC20, AccessControl {
    bytes32 public constant DATA_PROVIDER = keccak256("DATA_PROVIDER");
    bytes32 public constant MODEL_DEVELOPER = keccak256("MODEL_DEVELOPER");

    mapping(address => uint256) public tokenPrices; // Mapping of accepted tokens to their prices in wei
    address public dataNFTHolder;
    address payable public modelNFT;

    event TokensPurchased(address indexed purchaser, uint256 amount, address paymentToken);
    event AccessGranted(address indexed user);

    constructor(
        address dataProvider,
        address modelDeveloper,
        address payable _modelNFT,
        uint256 initialSupply,
        address initialOwner
    ) ERC20("SublicenseToken", "SLT") {
        _grantRole(DATA_PROVIDER, dataProvider);
        _grantRole(MODEL_DEVELOPER, modelDeveloper);
        _mint(initialOwner, initialSupply * 10 * decimals());
        dataNFTHolder = dataProvider;
        modelNFT = _modelNFT;
    }

    function mint(address to, uint256 amount) external onlyRole(DATA_PROVIDER) {
        _mint(to, amount);
    }

    modifier onlyDataNFTHolder() {
        require(msg.sender == dataNFTHolder, "Caller is not the DataNFT holder");
        _;
    }

    function setTokenPrice(address token, uint256 price) public onlyDataNFTHolder {
        tokenPrices[token] = price;
    }

    function buyTokens(address paymentToken, uint256 paymentAmount) public payable {
        uint256 amountToBuy;
        if (paymentToken == address(0)) { // Ether payment
            require(msg.value > 0, "You need to send some Ether to buy sublicense tokens");
            amountToBuy = msg.value;
        } else { // ERC20 token payment
            uint256 tokenPrice = tokenPrices[paymentToken];
            require(tokenPrice > 0, "This payment token is not accepted");
            amountToBuy = paymentAmount;
            require(IERC20(paymentToken).transferFrom(msg.sender, dataNFTHolder, paymentAmount), "Token transfer failed");
        }
        require(amountToBuy > 0, "Insufficient payment amount to buy tokens");

        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= amountToBuy, "Not enough tokens in the reserve");

        _transfer(address(this), msg.sender, amountToBuy);
        emit TokensPurchased(msg.sender, amountToBuy, paymentToken);
    }

    function withdrawEther(uint256 amount) external onlyDataNFTHolder payable {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(dataNFTHolder).transfer(amount);
    }

    function grantAccessToDataNFT(address payable dataNFTAddress, address user) public {
        DataNFT dataNFT = DataNFT(dataNFTAddress);
        require(balanceOf(user) > 0, "User does not own any sublicense tokens");
        dataNFT.grantAccess(user);
        emit AccessGranted(user);
    }

    function grantAccessToModelNFT(address user) external {
        require(balanceOf(user) > 0, "User does not own any sublicense tokens");
        ModelNFT(modelNFT).grantAccess(user);
        emit AccessGranted(user);
    }

    receive() external payable {
        revert("Direct Ether payments not accepted");
    }
}
