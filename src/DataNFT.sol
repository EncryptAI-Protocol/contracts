// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract DataNFT is ERC721, AccessControl {
    bytes32 public constant DATA_PROVIDER = keccak256("DATA_PROVIDER");

    string private ipfsURI;

    uint256 public price;
    uint256 public fee;

    event IPFSURISet(string indexed ipfsURI);
    event AccessGranted(address indexed user);
    event DataUsagePaid(address indexed payer, uint256 amount);
    event PredictionFeePaid(address indexed payer, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);

    constructor(string memory name,
                string memory symbol, 
                string memory _ipfsURI, 
                uint256 _price,
                uint256 _fee) ERC721(name, symbol) {
        _grantRole(DATA_PROVIDER, msg.sender);
        ipfsURI = _ipfsURI;
        price = _price;
        fee = _fee;

    }

    function safeDataMint(address to, uint256 tokenId) public onlyRole(DATA_PROVIDER) {
        _safeMint(to, tokenId);
    }
    

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setIPFSURI(string memory _ipfsURI) public onlyRole(DATA_PROVIDER) {
        ipfsURI = _ipfsURI;
        emit IPFSURISet(_ipfsURI);
    }

    function getIPFSURI() public view returns (string memory) {
        return ipfsURI;
    }

    function grantAccess(address user) external {
        // Check if the user has a balance greater than price or if they have paid the determined price
        require(balanceOf(user) >= price, "User does not own any tokens");
        emit AccessGranted(user);
    }
    
    function payForDataUsage() external payable {
        require(msg.value >= price, "Payment must be greater than zero");
        emit DataUsagePaid(msg.sender, msg.value);
    }
    // Function to collect fees from users computing predictions
    function payPredictionFee() external payable {
        require(msg.value >= fee, "Payment must be greater than zero");
        emit PredictionFeePaid(msg.sender, msg.value);
    }

    // Function for the owner to withdraw collected funds
    function withdrawFunds() external onlyRole(DATA_PROVIDER) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Withdrawal failed");

        emit Withdraw(msg.sender, balance);
    }

    // Function to receive Ether directly
    receive() external payable {}
}
