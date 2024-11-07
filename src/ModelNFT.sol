// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ModelNFT is ERC721, AccessControl {
    uint256 private _currentTokenId = 0;

    struct NFTAttributes {
        string name;
        string symbol;
        string ipfsURI;
        string icon;
        uint256 tokenPrice;
        uint256 fee;
        bytes32 modelHash; // hash of the model, to prevent duplicates
        string[] labels;
        string modelType;
        string desc;
    }

    struct NFTDetails {
        uint256 tokenId;
        NFTAttributes attributes;
        address owner;
    }

    mapping(uint256 => address) public _tokenMinters;
    mapping(bytes32 => bool) private _modelHashes;
    mapping(uint256 => NFTAttributes) private _tokenAttributes;

    event ModelNFTCreated(address indexed to, uint256 tokenId);

    constructor(address admin) ERC721("ModelNFT", "MNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function safeModelMint(
        address to,
        string memory name,
        string memory symbol,
        string memory ipfsURI,
        string memory icon,
        uint256 tokenPrice,
        uint256 fee,
        bytes32 modelHash,
        string[] memory labels,
        string memory modelType,
        string memory desc
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!_modelHashes[modelHash], "Model hash already exists"); // Check for duplicates
        uint256 tokenId = _currentTokenId++;
        _safeMint(to, tokenId);
        _tokenAttributes[tokenId] = NFTAttributes(name, symbol, ipfsURI, icon, tokenPrice, fee, modelHash, labels, modelType, desc);
        _modelHashes[modelHash] = true;
        _tokenMinters[tokenId] = to; // Record the minter of the token
        emit ModelNFTCreated(to, tokenId);
    }

    function getTokenAttributes(uint256 tokenId) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (NFTAttributes memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI set of nonexistent token");
        return _tokenAttributes[tokenId];
    }

    function getTokenOwner(uint256 tokenId) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (address) {
        return ownerOf(tokenId);
    }

    function setTokenPrice(uint256 tokenId, uint256 price) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI set of nonexistent token");
        _tokenAttributes[tokenId].tokenPrice = price;
    }

    function setTokenFee(uint256 tokenId, uint256 fee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI set of nonexistent token");
        _tokenAttributes[tokenId].fee = fee;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setTokenURI(uint256 tokenId, string memory _ipfsURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI set of nonexistent token");
        _tokenAttributes[tokenId].ipfsURI = _ipfsURI;
       // emit IPFSURISet(tokenId, _ipfsURI);
    }

    function getTokenURI(uint256 tokenId) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return _tokenAttributes[tokenId].ipfsURI;
    }

    function setTokenIcon(uint256 tokenId, string memory _icon) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI set of nonexistent token");
        _tokenAttributes[tokenId].icon = _icon;
    }

    function getAllMintedModelNFTs() public view onlyRole(DEFAULT_ADMIN_ROLE) returns (NFTDetails[] memory) {
        require(_currentTokenId > 0, "No ModelNFTs minted yet");
        
        uint256 validTokenCount = 0;
        for (uint256 i = 0; i <= _currentTokenId; i++) {
            if (_ownerOf(i) != address(0)) {
                validTokenCount++;
            }
        }

        NFTDetails[] memory allNFTs = new NFTDetails[](validTokenCount);
        uint256 index = 0;
        for (uint256 i = 0; i <= _currentTokenId; i++) {
            if (_ownerOf(i) != address(0)) {
                allNFTs[index] = NFTDetails({
                    tokenId: i,
                    attributes: _tokenAttributes[i],
                    owner: ownerOf(i)
                });
                index++;
            }
        }
        return allNFTs;
    }

    function burn(uint256 tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        _burn(tokenId);
        delete _modelHashes[_tokenAttributes[tokenId].modelHash];
        delete _tokenAttributes[tokenId];
        delete _tokenMinters[tokenId];
    }

    function withdrawFunds() external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Withdrawal failed");

        //emit Withdraw(msg.sender, balance);
    }

    function transferAdminRole(address newAdmin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
