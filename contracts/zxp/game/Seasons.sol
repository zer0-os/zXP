// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISeasonRegistry} from "./interfaces/ISeasonRegistry.sol";
import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {IStakerRewards} from "../mechanics/interfaces/IStakerRewards.sol";
import {IXP} from "./interfaces/IXP.sol";

contract Seasons is ObjectRegistryClient, ISeasonRegistry {
    uint public currentSeason;
    uint public stakerXPReward = 100;

    struct Season {
        string metadata;
        uint start;
        uint end;
        mapping(bytes32 name => address objectAddress) objects;
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

    function onUnstake(
        uint id,
        address to,
        uint stakedAt
    ) external override only(GAME_VAULT) {
        IStakerRewards(addressOf(currentSeason, STAKER_REWARDS)).onUnstake(
            id,
            to,
            stakedAt
        );
        IXP(registry.addressOf(game, XP)).awardXP(
            to,
            stakerXPReward * (block.number - stakedAt)
        );
    }

    function awardXP(address to, uint amount) public override {
        IXP(registry.addressOf(game, XP)).awardXP(to, amount);
    }
}