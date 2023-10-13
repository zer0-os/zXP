// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SeasonManager is ISeasonManager {
    mapping(uint season => mapping(bytes32 name => address mechanic))
        private seasonMechanics;

    function mechanic(
        uint256 season,
        bytes32 name
    ) public view override returns (address) {
        return seasonMechanics[season][name];
    }

    function registerMechanic(
        uint season,
        bytes32 name,
        address mechanicAddress
    ) public ownerOnly validAddress(_contractAddress) {
        require(_contractName.length > 0, "ERR_INVALID_NAME");
        //Prevent overwrite
        //require(addressOf(_contractName, currentSeason + 1) == address(0), "ERR_NAME_TAKEN");
        seasonMechanics[season][name] = mechanicAddress;
    }
}
