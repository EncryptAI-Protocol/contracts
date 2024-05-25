// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IDataNFT {
    function payForDataUsage() external payable;
    
}

contract ModelNFT is ERC721, AccessControl {
    bytes32 public constant CONSUMER = keccak256("CONSUMER");
    bytes32 public constant MODEL_DEVELOPER = keccak256("MODEL_DEVELOPER");

    string private ipfsURI;
    address public dataNFTAddress;

    event IPFSURISet(string indexed ipfsURI);
    event AccessGranted(address indexed user);
    event DataUsagePaid(address indexed payer, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);

    constructor(address modelDeveloper,
                address consumer, 
                string memory name,
                string memory symbol,
                address _dataNFTAddress) ERC721(name, symbol) {
        _grantRole(MODEL_DEVELOPER, modelDeveloper);
        _grantRole(CONSUMER, consumer);
        dataNFTAddress = _dataNFTAddress;
    }

    function safeDataMint(address to, uint256 tokenId) public onlyRole(MODEL_DEVELOPER) {
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

    function setIPFSURI(string memory _ipfsURI) public onlyRole(MODEL_DEVELOPER) {
        ipfsURI = _ipfsURI;
        emit IPFSURISet(_ipfsURI);
    }

    function getIPFSURI() public view returns (string memory) {
        return ipfsURI;
    }

    function grantAccess(address user) external {
        // Check if the user has a balance greater than zero or if they have paid the determined price
        require(balanceOf(user) > 0, "User does not own any tokens");
        emit AccessGranted(user);
    }
    
    function payForModelUsage() external payable onlyRole(CONSUMER) {
        require(msg.value > 0, "Payment must be greater than zero");
        emit DataUsagePaid(msg.sender, msg.value);
    }

    function payDataNFT(uint256 amount) external onlyRole(MODEL_DEVELOPER){
        require(amount > 0, "Amount must be greater than zero");
        require(address(this).balance >= amount, "Insufficient Balance");

        IDataNFT(dataNFTAddress).payForDataUsage{value: amount}();
    }

    // Function for the owner to withdraw collected funds
    function withdrawFunds() external onlyRole(MODEL_DEVELOPER) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Withdrawal failed");

        emit Withdraw(msg.sender, balance);
    }

    // Function to receive Ether directly
    receive() external payable {}
}
