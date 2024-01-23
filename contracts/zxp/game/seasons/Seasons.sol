// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ISeasons} from "../interfaces/ISeasons.sol";
import {ObjectRegistry, IObjectRegistry} from "../../ObjectRegistry.sol";
import {ObjectRegistryClient} from "../../ObjectRegistryClient.sol";
import {IStakerRewards} from "./mechanics/interfaces/IStakerRewards.sol";
import {IXP} from "../interfaces/IXP.sol";

contract Seasons is ObjectRegistryClient, ISeasons, Ownable {
    bytes32 internal constant GAME_VAULT = "GameVault";
    bytes32 internal constant STAKER_REWARDS = "StakerRewards";
    bytes32 internal constant XP = "XP";
    uint public currentSeason;
    uint public stakerXPReward = 100;

    struct Season {
        string metadata;
        uint start;
        uint end;
        ObjectRegistry objects;
    }
    mapping(uint season => Season data) public seasons;

    modifier preseason(uint season) {
        require(seasons[season].start == 0, "ZXP: Season started");
        _;
    }

    modifier onlyRegistered(bytes32 object) {
        require(
            address(
                ObjectRegistry(seasons[currentSeason].objects.addressOf(object))
            ) != address(0),
            "ZXP: Object not registered"
        );
        _;
    }

    constructor(IObjectRegistry registry) ObjectRegistryClient(registry) {
        Ownable(msg.sender);
        seasons[currentSeason].objects = new ObjectRegistry(msg.sender);
    }

    function getRegistryAddress(
        uint season
    ) external view override returns (address) {
        return address(seasons[season].objects);
    }

    function startSeason()
        external
        override
        onlyOwner
        preseason(currentSeason)
    {
        seasons[currentSeason].start = block.number;
    }

    /**
        @dev sets currentSeason.end and increments currentSeason
     */
    function endSeason() external override onlyOwner {
        require(seasons[currentSeason].start != 0, "ZXP season not started");
        seasons[currentSeason].end = block.number;
        currentSeason++;
        seasons[currentSeason].objects = new ObjectRegistry(msg.sender);
    }

    function onUnstake(
        uint id,
        address to,
        uint stakedAt
    ) external override only(GAME_VAULT) {
        IStakerRewards(seasons[currentSeason].objects.addressOf(STAKER_REWARDS))
            .onUnstake(id, to, stakedAt);
        IXP(registry.addressOf(XP)).awardXP(
            to,
            stakerXPReward * (block.number - stakedAt)
        );
    }

    function awardXP(
        address to,
        uint amount,
        bytes32 object
    ) public override onlyRegistered(object) {
        IXP(registry.addressOf(XP)).awardXP(to, amount);
    }
}