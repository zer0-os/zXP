// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ITop3Rewards} from "./interfaces/ITop3Rewards.sol";

contract Top3Rewards is Ownable, ITop3Rewards {
    IERC20 public rewardToken;
    mapping(address awardee => uint amount) public rewards;

    constructor(address owner, IERC20 erc20RewardToken) {
        rewardToken = erc20RewardToken;
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
    }
}