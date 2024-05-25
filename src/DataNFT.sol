// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract DataNFT is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private ipfsURI;

    event IPFSURISet(string indexed ipfsURI);
    event AccessGranted(address indexed user);

    constructor(address defaultAdmin, 
                address minter, 
                string memory name,
                string memory symbol) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function safeMint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
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

    function setIPFSURI(string memory _ipfsURI) public onlyRole(MINTER_ROLE) {
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
}
