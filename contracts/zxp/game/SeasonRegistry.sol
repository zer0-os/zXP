// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISeasonRegistry} from "./interfaces/ISeasonRegistry.sol";
import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {IStakerRewards} from "../mechanics/interfaces/IStakerRewards.sol";

contract SeasonRegistry is GameRegistryClient, ISeasonRegistry {
    bytes32 internal constant OWNER = "Owner";
    bytes32 internal constant STAKER_REWARDS = "StakerRewards";
    uint public currentSeason;
    struct Season {
        string metadata;
        uint start;
        uint end;
        mapping(bytes32 name => address mechanicAddress) mechanics;
    }
    mapping(uint season => Season data) public seasons;

    modifier preseason(uint season) {
        require(seasons[season].start == 0, "ZXP: Season started");
        _;
    }

    constructor(
        IGameRegistry registry,
        bytes32 game
    ) GameRegistryClient(registry, game) {}

    function registerMechanics(
        bytes32[] calldata mechanicNames,
        address[] calldata mechanicAddresses
    ) public override only(OWNER) preseason(currentSeason) {
        require(mechanicNames.length > 0, "ZXP: Invalid name");
        for (uint256 i = 0; i < mechanicNames.length; i++) {
            seasons[currentSeason].mechanics[
                mechanicNames[i]
            ] = mechanicAddresses[i];
        }
    }

    function startSeason()
        external
        override
        only(OWNER)
        preseason(currentSeason)
    {
        seasons[currentSeason].start = block.number;
    }

    /**
        @dev sets currentSeason.end and increments currentSeason
     */
    function endSeason() external override only(OWNER) {
        require(seasons[currentSeason].start != 0, "ZXP season not started");
        seasons[currentSeason].end = block.number;
        currentSeason++;
    }

    function addressOf(
        uint256 season,
        bytes32 name
    ) public view override returns (address) {
        return seasons[season].mechanics[name];
    }

    function onUnstake(uint id, address to, uint stakedAt) external override {
        IStakerRewards(addressOf(currentSeason, STAKER_REWARDS)).onUnstake(
            id,
            to,
            stakedAt
        );
    }
}
