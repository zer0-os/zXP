// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IPlayerRewards} from "./interfaces/IPlayerRewards.sol";
import {ObjectRegistryClient} from "../../../ObjectRegistryClient.sol";
import {IObjectRegistry} from "../../../interfaces/IObjectRegistry.sol";
import {ISeasons} from "../../interfaces/ISeasons.sol";


contract PlayerRewards is ObjectRegistryClient, Ownable, IPlayerRewards {
    bytes32 internal constant name = "PlayerRewards";
    IERC20 public rewardToken;
    uint public xpReward;
    ISeasons private season;
    mapping(address awardee => uint amount) public rewards;

    constructor(
        address owner,
        IERC20 erc20RewardToken,
        ISeasons seasonManager,
        uint xpRewarded
    )
    // this seems to be called on every single contract. what is the point of it?
    // if we already have access to this value, why do we need to write it in every single state?
        ObjectRegistryClient(
            IObjectRegistry(
                seasonManager.getRegistryAddress(seasonManager.currentSeason())
            )
        )
    {
        rewardToken = erc20RewardToken;
        xpReward = xpRewarded;
        season = seasonManager;
        Ownable(owner);
    }

    function claim(address to) external override {
        rewardToken.transfer(to, rewards[to]);
    }

    // when is this called? why 3 results?
    // why not addresses and uints arrays?
    // also, what is the point of this contract if the decision to disperse
    // rewards is made by the caller by an external call at arbitrary time?
    // we can just do this all off-chain and the result seems the same
    // from the trust standpoint
    function submitTop3Results(
        address first,
        address second,
        address third,
        uint firstReward,
        uint secondReward,
        uint thirdReward
    ) external override onlyOwner {
        rewardToken.transfer(first, firstReward);
        rewardToken.transfer(second, secondReward);
        rewardToken.transfer(third, thirdReward);
        season.awardXP(first, xpReward * 3, name);
        season.awardXP(second, xpReward * 2, name);
        season.awardXP(third, xpReward, name);
    }
}
