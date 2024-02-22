// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISeasons} from "../interfaces/ISeasons.sol";
import {ObjectRegistry, IObjectRegistry} from "../../ObjectRegistry.sol";
import {ObjectRegistryClient} from "../../ObjectRegistryClient.sol";
import {IStakerRewards} from "./mechanics/interfaces/IStakerRewards.sol";
import {IXP} from "../interfaces/IXP.sol";

contract Seasons is ObjectRegistryClient, ISeasons {
    bytes32 internal constant OWNER = "Owner";
    bytes32 internal constant GAME_VAULT = "GameVault";
    bytes32 internal constant STAKER_REWARDS = "StakerRewards";
    bytes32 internal constant XP = "XP";
    uint public currentSeason;
    uint private constant STAKER_XP_REWARD = 100;

    struct Season {
        string metadata;
        uint start;
        uint end;
        ObjectRegistry seasonObjects;
    }
    mapping(uint season => Season data) public seasons;

    modifier preseason(uint season) {
        require(seasons[season].start == 0, "ZXP: Season started");
        _;
    }

    // ZXP modifier in seasons?
    modifier onlyRegistered(address object, bytes32 name) {
        require(
            address(
                ObjectRegistry(
                    seasons[currentSeason].seasonObjects.addressOf(name)
                )
            ) == object,
            "ZXP: Object not registered"
        );
        _;
    }

    constructor(IObjectRegistry registry) ObjectRegistryClient(registry) {
        seasons[currentSeason].seasonObjects = new ObjectRegistry(msg.sender);
    }

    function getRegistryAddress(
        uint season
    ) external view override returns (address) {
        return address(seasons[season].seasonObjects);
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
        seasons[currentSeason].seasonObjects = new ObjectRegistry(msg.sender);
    }

    function onUnstake(
        uint id,
        address to,
        uint stakedAt
    ) external override only(GAME_VAULT) {
        IStakerRewards(
            seasons[currentSeason].seasonObjects.addressOf(STAKER_REWARDS)
        ).onUnstake(id, to, stakedAt);
        IXP(registry.addressOf(XP)).awardXP(
            to,
            STAKER_XP_REWARD * (block.number - stakedAt)
            // TODO are `rewardsPerBlock` and `STAKER_XP_REWARD` expected to be the same?
        );
    }

    function awardXP(
        address to,
        uint amount,
        bytes32 objectName
    ) public override onlyRegistered(msg.sender, objectName) {
        IXP(registry.addressOf(XP)).awardXP(to, amount);
    }
}
