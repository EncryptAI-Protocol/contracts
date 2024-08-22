// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

struct Information {
    string name;
    string symbol;
    string hash;
    uint256 price;
    string[] labels;
}

contract ModelSource is ERC721, ERC721URIStorage, AccessControl {
    bytes32 public constant MODEL_DEVELOPER = keccak256("MODEL_DEVELOPER");

    string private uri;

    string[] public labels;
    string public hash;
    uint256 public price;
    uint256 public fee;

    constructor(
        address defaultAdmin,
        address minter,
        string memory _name,
        string memory _symbol,
        string memory _hash,
        string memory _uri,
        string[] memory _labels,
        uint256 _price
    ) ERC721(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MODEL_DEVELOPER, minter);

        hash = _hash;
        uri = _uri;
        price = _price;
        labels = _labels;
    }

    function safeMint(address to, uint256 tokenId) public onlyRole(MODEL_DEVELOPER) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getInfo() public view returns (Information memory) {
        return Information(super.name(), super.symbol(), hash, price, labels);
    }
}
