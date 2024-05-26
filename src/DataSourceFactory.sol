// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DataSource.sol";

contract DataSourceFactory {
    DataSource[] public dataSources;

    event DataSourceCreated(address ownerAddress, address dataAddress, string name, uint256 price, uint256 fee);

    function createDataSource(
        string calldata _name,
        string calldata _symbol,
        string calldata _uri,
        string calldata _hash,
        string[] memory _labels,
        uint256 _price,
        uint256 _fee
    ) external {
        DataSource dataSource =
            new DataSource(msg.sender, msg.sender, _name, _symbol, _hash, _uri, _price, _fee, _labels);

        dataSources.push(dataSource);

        emit DataSourceCreated(msg.sender, address(dataSource), _name, _price, _fee);
    }

    function getDataSources(uint256 limit) external view returns (Information[] memory) {
        if (limit > dataSources.length) {
            limit = dataSources.length;
        }

        Information[] memory info = new Information[](limit);

        for (uint256 i = 0; i < limit; i++) {
            info[i] = DataSource(dataSources[i]).getInfo();
        }

        return info;
    }
}
