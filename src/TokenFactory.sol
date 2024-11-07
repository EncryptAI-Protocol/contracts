// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DataNFT.sol";
import "./ModelNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenFactory is Ownable {
    DataNFT public dataNFT;
    ModelNFT public modelNFT;

    constructor(
        address defaultAdmin,
        address _dataNFTAddress,
        address _modelNFTAddress
        ) Ownable(defaultAdmin) {
        dataNFT = DataNFT(_dataNFTAddress);
        modelNFT = ModelNFT(_modelNFTAddress);
    }

    function createDataNFT(
        address to,
        string memory name,
        string memory symbol,
        string memory ipfsURI,
        string memory icon,
        uint256 tokenPrice,
        uint256 fee,
        bytes32 datasetHash,
        string[] memory labels,
        string memory desc
    ) public {
        dataNFT.safeDataMint(to, name, symbol, ipfsURI, icon, tokenPrice, fee, datasetHash, labels, desc);
    }

    function createModelNFT(
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
    ) public {
        modelNFT.safeModelMint(to, name, symbol, ipfsURI, icon, tokenPrice, fee, modelHash, labels, modelType, desc);
    }

    function getDataTokenAttributes(uint256 tokenId) public view returns (DataNFT.NFTAttributes memory) {
        return dataNFT.getTokenAttributes(tokenId);
    }

    function setDataTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(dataNFT.ownerOf(tokenId) == msg.sender, "Caller is not the owner of this token");
        dataNFT.setTokenURI(tokenId, tokenURI);
    }

    function getDataTokenURI(uint256 tokenId) public view returns (string memory) {
        return dataNFT.getTokenURI(tokenId);
    }

    function setDataTokenPrice(uint256 tokenId, uint256 price) public {
        require(dataNFT.ownerOf(tokenId) == msg.sender, "Caller is not the owner of this token");
        dataNFT.setTokenPrice(tokenId, price);
    }

    function setDataTokenFee(uint256 tokenId, uint256 fee) public {
        require(dataNFT.ownerOf(tokenId) == msg.sender, "Caller is not the owner of this token");
        dataNFT.setTokenFee(tokenId, fee);
    }

    function getAllMintedDataNFTs() public view returns (DataNFT.NFTDetails[] memory) {
        return dataNFT.getAllMintedDataNFTs();
    }

    function burnDataNFT(uint256 tokenId) public {
        require(dataNFT.ownerOf(tokenId) == msg.sender, "Caller is not the owner of this token");
        dataNFT.burn(tokenId);
    }

    function getModelTokenAttributes(uint256 tokenId) public view returns (ModelNFT.NFTAttributes memory) {
        return modelNFT.getTokenAttributes(tokenId);
    }

    function setModelTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(modelNFT.ownerOf(tokenId) == msg.sender, "Caller is not the owner of this token");
        modelNFT.setTokenURI(tokenId, tokenURI);
    }

    function getModelTokenURI(uint256 tokenId) public view returns (string memory) {
        return modelNFT.getTokenURI(tokenId);
    }

    function setModelTokenPrice(uint256 tokenId, uint256 price) public {
        require(modelNFT.ownerOf(tokenId) == msg.sender, "Caller is not the owner of this token");
        modelNFT.setTokenPrice(tokenId, price);
    }

    function setModelTokenFee(uint256 tokenId, uint256 fee) public {
        require(modelNFT.ownerOf(tokenId) == msg.sender, "Caller is not the owner of this token");
        modelNFT.setTokenFee(tokenId, fee);
    }

    function getAllMintedModelNFTs() public view returns (ModelNFT.NFTDetails[] memory) {
        return modelNFT.getAllMintedModelNFTs();
    }

    function burnModelNFT(uint256 tokenId) public {
        require(modelNFT.ownerOf(tokenId) == msg.sender, "Caller is not the owner of this token");
        modelNFT.burn(tokenId);
    }
}