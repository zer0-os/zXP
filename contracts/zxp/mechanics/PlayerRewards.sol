// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IPlayerRewards} from "./interfaces/IPlayerRewards.sol";
import {SeasonRegistryClient} from "../game/SeasonRegistryClient.sol";
import {ISeasonRegistry} from "../game/interfaces/ISeasonRegistry.sol";

contract PlayerRewards is SeasonRegistryClient, Ownable, IPlayerRewards {
    IERC20 public rewardToken;
    uint public xpReward;
    mapping(address awardee => uint amount) public rewards;

    constructor(
        address owner,
        IERC20 erc20RewardToken,
        ISeasonRegistry registry,
        uint season,
        uint xpRewarded
    ) SeasonRegistryClient(registry, season) Ownable(owner) {
        rewardToken = erc20RewardToken;
        xpReward = xpRewarded;
    }

    function claim(address to) external override {
        rewardToken.transfer(to, rewards[to]);
    }

    function submitTop3Results(
        address first,
        address second,
        address third,
        uint firstReward,
        uint secondReward,
        uint thirdReward
    ) external override onlyOwner {
        rewards[first] += firstReward;
        rewards[second] += secondReward;
        rewards[third] += thirdReward;
        registry.awardXP(first, xpReward);
        registry.awardXP(second, xpReward);
        registry.awardXP(third, xpReward);
    }
}
