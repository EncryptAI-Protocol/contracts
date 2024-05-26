// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DataNFT.sol";
import "./SublicenseToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DataNFTFactory is Ownable {
    DataNFT[] public dataNFTs;
    SublicenseToken[] public sublicenseTokens;

    bytes32 public constant ASSET_PROVIDER = keccak256(abi.encodePacked("ASSET_PROVIDER"));

    constructor(address defaultAdmin) Ownable(defaultAdmin) {}

    event DataNFTCreated(address dataNFTHolder, address dataNFTAddress, address sublicenseTokenAddress);

    function createDataNFT(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        string memory ipfsURI,
        address paymentToken,
        uint256 tokenPrice,
        uint256 fee,
        address assetProviderAddress
    ) public {
        // Deploy a new DataNFT contract
        DataNFT dataNFT = new DataNFT(name, symbol, ipfsURI, tokenPrice, fee);
        dataNFT.setIPFSURI(ipfsURI); // Set the IPFS URI for the data

        // Deploy a new SublicenseToken contract
        SublicenseToken sublicenseToken = new SublicenseToken(
            assetProviderAddress, // dataProvider
            initialSupply,
            msg.sender // initialOwner
        );
        sublicenseToken.setTokenPrice(paymentToken, tokenPrice); // Set the initial token price for the tokens

        // Store the contracts in arrays
        dataNFTs.push(dataNFT);
        sublicenseTokens.push(sublicenseToken);

        emit DataNFTCreated(msg.sender, address(dataNFT), address(sublicenseToken));
    }

    function setSublicenseTokenPrice(address payable sublicenseTokenAddress, address paymentToken, uint256 price)
        public
    {
        SublicenseToken sublicenseToken = SublicenseToken(sublicenseTokenAddress);
        require(sublicenseToken.hasRole(ASSET_PROVIDER, msg.sender), "Only the DataNFT holder can set the price");
        sublicenseToken.setTokenPrice(paymentToken, price);
    }

    function getDeployedDataNFTs() public view returns (DataNFT[] memory) {
        return dataNFTs;
    }

    function getDeployedSublicenseTokens() public view returns (SublicenseToken[] memory) {
        return sublicenseTokens;
    }
}
