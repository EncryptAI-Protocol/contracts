// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract DataNFT is ERC721, AccessControl {
    uint256 private _currentTokenId = 0;

    struct NFTAttributes {
        string name;
        string symbol;
        string ipfsURI;
        uint256 tokenPrice;
        uint256 fee;
        bytes32 datasetHash; // dataset hash, to prevent duplicates
    }

    // Mapping to track existing dataset hashes
    mapping(uint256 => address) private _tokenMinters;
    mapping(bytes32 => bool) private _datasetHashes;
    mapping(uint256 => NFTAttributes) private _tokenAttributes;

    event DataNFTCreated(address indexed to, uint256 tokenId);

    constructor() ERC721("DataNFT", "DNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function safeDataMint(
        address to,
        string memory name,
        string memory symbol,
        string memory ipfsURI,
        uint256 tokenPrice,
        uint256 fee,
        bytes32 datasetHash
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!_datasetHashes[datasetHash], "Dataset hash already exists"); // Check for duplicates
        uint256 tokenId = _currentTokenId++;
        _safeMint(to, tokenId);
        _tokenAttributes[tokenId] = NFTAttributes(name, symbol, ipfsURI, tokenPrice, fee, datasetHash);
        _datasetHashes[datasetHash] = true;
        _tokenMinters[tokenId] = to; // Record the minter of the token
        emit DataNFTCreated(to, tokenId);
    }

    function getTokenAttributes(uint256 tokenId) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (NFTAttributes memory) {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        return _tokenAttributes[tokenId];
    }

    function setTokenPrice(uint256 tokenId, uint256 price) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenAttributes[tokenId].tokenPrice = price;
    }

    function setTokenFee(uint256 tokenId, uint256 fee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenAttributes[tokenId].fee = fee;
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setTokenURI(uint256 tokenId, string memory _ipfsURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenAttributes[tokenId].ipfsURI = _ipfsURI;
       // emit IPFSURISet(tokenId, _ipfsURI);
    }

    function getTokenURI(uint256 tokenId) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenAttributes[tokenId].ipfsURI;
    }
    /*
    function grantAccess(address user) external {
        // Check if the user has a balance greater than price or if they have paid the determined price
        require(balanceOf(user) >= price, "User does not own enough tokens");
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
    */

    // Function for the owner to withdraw collected funds
    function withdrawFunds() external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Withdrawal failed");

        //emit Withdraw(msg.sender, balance);
    }

    // Function to receive Ether directly
    receive() external payable {}
}
