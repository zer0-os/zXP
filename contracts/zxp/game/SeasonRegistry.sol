// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISeasonRegistry} from "./interfaces/ISeasonRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";

contract SeasonRegistry is GameRegistryClient, ISeasonRegistry {
    bytes32 internal constant OWNER = "Owner";
    uint public currentSeason;
    struct Season {
        string description;
        uint start;
        uint end;
        mapping(bytes32 name => address mechanicAddress) mechanics;
    }
    mapping(uint season => Season data) public seasons;

    modifier seasonStarted(uint season, bool ){
        require(seasons[season].start == 0, "ZXP: Season started");
    }

    function _seasonStarted()

    function registerMechanics(
        uint season,
        bytes32[] mechanicNames,
        address[] mechanicAddress
    ) public override only(OWNER) {
        require(seasons[season].start == 0, "ZXP: Season started");
        require(_contractNames.length > 0, "ZXP: Invalid name");
        for (uint256 i = 0; i < mechanicNames.length; i++) {
            seasons[season].mechanics[mechanicNames[i]] = mechanicAddresses[i];
        }
    }

    function initializeSeason(
        uint season,
        string calldata description,
        bytes32[] mechanicNames,
        address[] mechanicAddresses
    ) external override only(OWNER) {
        require(seasons[season].start == 0, "ZXP season started");
        seasons[season] = Season(description, 0, 0);
        registerMechanics(mechanicNames, mechanicAddresses);
    }

    function startSeason(uint season) external override only(OWNER) {
        seasons[season].start = block.timestamp;
    }

    function endSeason(uint season) external override only(OWNER) {
        require(seasons[season].start != 0, "ZXP season not started");
        seasons[season].end = block.timestamp;
    }

    function addressOf(
        uint256 season,
        bytes32 name
    ) public view override returns (address) {
        return seasons[season].mechanics[name];
    }
}
