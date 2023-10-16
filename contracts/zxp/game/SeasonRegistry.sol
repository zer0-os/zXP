// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISeasonRegistry} from "./interfaces/ISeasonRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";

contract SeasonRegistry is GameRegistryClient, ISeasonRegistry {
    bytes32 internal constant OWNER = "Owner";
    struct Season {
        uint number;
        uint start;
        uint end;
        mapping(bytes32 name => address mechanic) mechanics;
    }

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
    ) public override only(OWNER) {
        require(_contractName.length > 0, "ERR_INVALID_NAME");
        //Prevent overwrite
        //require(addressOf(_contractName, currentSeason + 1) == address(0), "ERR_NAME_TAKEN");
        seasonMechanics[season][name] = mechanicAddress;
    }

    function startSeason(uint season) external override {
        seasonStarted[season] = true;
    }

    function endSeason(uint season) external override {
        seasonEnded[season] = true;
    }
}
