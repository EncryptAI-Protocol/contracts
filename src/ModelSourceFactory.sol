// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ModelSource.sol";

contract ModelSourceFactory {
    ModelSource[] public modelSources;

    event ModelSourceCreated(address ownerAddress, address dataAddress, string name, uint256 price);

    function createModelSource(
        string calldata _name,
        string calldata _symbol,
        string calldata _uri,
        string calldata _hash,
        string[] memory _labels,
        uint256 _price
    ) external {
        ModelSource modelSource = new ModelSource(msg.sender, msg.sender, _name, _symbol, _hash, _uri, _labels, _price);

        modelSources.push(modelSource);

        emit ModelSourceCreated(msg.sender, address(modelSource), _name, _price);
    }

    function getModelSources(uint256 limit) external view returns (Information[] memory) {
        if (limit > modelSources.length) {
            limit = modelSources.length;
        }

        Information[] memory info = new Information[](limit);

        for (uint256 i = 0; i < limit; i++) {
            info[i] = ModelSource(modelSources[i]).getInfo();
        }

        return info;
    }
}
