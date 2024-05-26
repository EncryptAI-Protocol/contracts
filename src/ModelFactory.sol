// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ModelNFT.sol";
import "./SublicenseToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ModelNFTFactory is Ownable {
    ModelNFT[] public modelNFTs;
    SublicenseToken[] public sublicenseTokens;

    bytes32 public constant ASSET_PROVIDER = keccak256(abi.encodePacked("ASSET_PROVIDER"));

    constructor(address defaultAdmin) Ownable(defaultAdmin) {}

    event ModelNFTCreated(address modelNFTHolder, address modelNFTAddress, address sublicenseTokenAddress);

    function createModelNFT(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        string memory ipfsURI,
        address paymentToken,
        uint256 modelPrice,
        uint256 tokenPrice,
        address dataNFTAddress,
        address assetProviderAddress
    ) public {
        // Deploy a new DataNFT contract
        ModelNFT modelNFT = new ModelNFT(name, symbol, ipfsURI, dataNFTAddress, modelPrice);
        modelNFT.setIPFSURI(ipfsURI); // Set the IPFS URI for the data

        // Deploy a new SublicenseToken contract
        SublicenseToken sublicenseToken = new SublicenseToken(
            assetProviderAddress, // dataProvider
            initialSupply,
            msg.sender // initialOwner
        );
        sublicenseToken.setTokenPrice(paymentToken, tokenPrice); // Set the initial token price for the tokens

        // Store the contracts in arrays
        modelNFTs.push(modelNFT);
        sublicenseTokens.push(sublicenseToken);

        emit ModelNFTCreated(msg.sender, address(modelNFT), address(sublicenseToken));
    }

    function setSublicenseTokenPrice(address payable sublicenseTokenAddress, address paymentToken, uint256 price)
        public
    {
        SublicenseToken sublicenseToken = SublicenseToken(sublicenseTokenAddress);
        require(sublicenseToken.hasRole(ASSET_PROVIDER, msg.sender), "Only the DataNFT holder can set the price");
        sublicenseToken.setTokenPrice(paymentToken, price);
    }

    function getDeployedModelNFTs() public view returns (ModelNFT[] memory) {
        return modelNFTs;
    }

    function getDeployedSublicenseTokens() public view returns (SublicenseToken[] memory) {
        return sublicenseTokens;
    }
}
