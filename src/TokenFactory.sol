// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DataNFT.sol";
import "./EncryptAIToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenFactory is Ownable {
    DataNFT public dataNFT;
    EncryptAIToken public encryptAIToken;
    //bytes32 public constant DATA_PROVIDER = keccak256("DATA_PROVIDER"); not used, controlling access throught _tokenMinters

    constructor(address defaultAdmin) Ownable(defaultAdmin) {
        // Deploy the DataNFT contract
        dataNFT = new DataNFT();
        // Deploy the EncryptAIToken contract
        encryptAIToken = new EncryptAIToken(msg.sender, 1000000);
    }

    function createDataNFT(
        address to,
        string memory name,
        string memory symbol,
        string memory ipfsURI,
        uint256 tokenPrice,
        uint256 fee,
        bytes32 datasetHash
    ) public {
        // Mint a new DataNFT with specific attributes
        dataNFT.safeDataMint(to, name, symbol, ipfsURI, tokenPrice, fee, datasetHash);
        //grantRole(DATA_PROVIDER, to);
    }

    function getTokenAttributes(uint256 tokenId) public view returns (DataNFT.NFTAttributes memory) {
        return dataNFT.getTokenAttributes(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(dataNFT._tokenMinters(tokenId) == msg.sender, "Caller is not the minter of this token");
        dataNFT.setTokenURI(tokenId, tokenURI);
    }

     function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return dataNFT.tokenURI(tokenId);
    }

    function setTokenPrice(uint256 tokenId, uint256 price) public {
        require(dataNFT._tokenMinters(tokenId) == msg.sender, "Caller is not the minter of this token");
        dataNFT.setTokenPrice(tokenId, price);
    }

    function setTokenFee(uint256 tokenId, uint256 fee) public {
        require(dataNFT._tokenMinters(tokenId) == msg.sender, "Caller is not the minter of this token");
        dataNFT.setTokenFee(tokenId, fee);
    }

    function burnDataNFT(uint256 tokenId) public {
        require(dataNFT._tokenMinters(tokenId) == msg.sender, "Caller is not the minter of this token");
        dataNFT.burn(tokenId);
    }

    //function setEncryptAITokenPrice(address payable encryptAITokenAddress, uint256 price) public {
    //    EncryptAIToken encryptAIToken = EncryptAIToken(encryptAITokenAddress);
    //    require(encryptAIToken.hasRole(DATA_NFT_PROVIDER, msg.sender), "Only the DataNFT holder can set the price");
    //    encryptAIToken.setTokenPrice(price);
    //}

    /* since we are only deploying one instance of each contract, we might not need these functions

    function getDeployedDataNFTs() public view returns (DataNFT[] memory) {
        return dataNFTs;
    }

    function getDeployedEncryptAITokens() public view returns (EncryptAIToken[] memory) {
        return encryptAITokens;
    }
    */
}
