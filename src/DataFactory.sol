// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DataNFT.sol";
import "./SublicenseToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DataNFTFactory is Ownable {
    DataNFT[] public dataNFTs;
    SublicenseToken[] public sublicenseTokens;
    
    constructor(address defaultAdmin,
                address minter,  
                string memory name, 
                string memory symbol, 
                uint256 initialSupply)
        Ownable(defaultAdmin)
    {
 
     }

    event DataNFTCreated(address dataNFTHolder, address dataNFTAddress, address sublicenseTokenAddress);

    function createDataNFT(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        string memory ipfsURI,
        address paymentToken,
        uint256 tokenPrice
    ) public {
        // Deploy a new DataNFT contract
        DataNFT dataNFT = new DataNFT(msg.sender, msg.sender, name, symbol);
        //dataNFT.transferOwnership(msg.sender);  // Transfer ownership to the caller
        dataNFT.setIPFSURI(ipfsURI);  // Set the IPFS URI for the data

        // Deploy a new SublicenseToken contract
        SublicenseToken sublicenseToken = new SublicenseToken(initialSupply, msg.sender);
        sublicenseToken.setTokenPrice(paymentToken, tokenPrice);  // Set the initial token price for the tokens

        // Store the contracts in arrays
        dataNFTs.push(dataNFT);
        sublicenseTokens.push(sublicenseToken);

        emit DataNFTCreated(msg.sender, address(dataNFT), address(sublicenseToken));
    }

    function setSublicenseTokenPrice(address payable sublicenseTokenAddress, address paymentToken, uint256 price) public {
        SublicenseToken sublicenseToken = SublicenseToken(sublicenseTokenAddress);
        require(sublicenseToken.dataNFTHolder() == msg.sender, "Only the DataNFT holder can set the price");
        sublicenseToken.setTokenPrice(paymentToken, price);
    }

    function getDeployedDataNFTs() public view returns (DataNFT[] memory) {
        return dataNFTs;
    }

    function getDeployedSublicenseTokens() public view returns (SublicenseToken[] memory) {
        return sublicenseTokens;
    }
}
