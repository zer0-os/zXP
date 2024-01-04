// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IPlayerRewards} from "./interfaces/IPlayerRewards.sol";
import {ObjectRegistryClient} from "../ObjectRegistryClient.sol";
import {IObjectRegistry} from "../interfaces/IObjectRegistry.sol";
import {ISeasons} from "../game/interfaces/ISeasons.sol";

contract PlayerRewards is ObjectRegistryClient, Ownable, IPlayerRewards {
    IERC20 public rewardToken;
    uint public xpReward;
    ISeasons private season;
    mapping(address awardee => uint amount) public rewards;

    constructor(
        address owner,
        IERC20 erc20XPToken,
        IERC20 erc20RewardToken,
        ISeasons seasonManager,
        uint xpRewarded
    )
        ObjectRegistryClient(
            IObjectRegistry(
                seasonManager.getObjectsAddress(seasonManager.currentSeason())
            )
        )
    {
        rewardToken = erc20RewardToken;
        xpToken = erc20XPToken;
        xpReward = xpRewarded;
        season = seasonManager;
        Ownable(owner);
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
        xpToken.transfer(first, xpReward * 3);
        xpToken.transfer(second, xpReward * 2);
        xpToken.transfer(third, xpReward);
    }
}
