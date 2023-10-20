// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStakerRewards} from "./interfaces/IStakerRewards.sol";

contract StakerRewards is IStakerRewards {
    IERC20 public rewardToken;
    uint public rewardPerBlock;
    mapping(address awardee => uint amount) public rewards;

    constructor(IERC20 erc20RewardToken, uint tokenRewardPerBlock) {
        rewardToken = erc20RewardToken;
        rewardPerBlock = tokenRewardPerBlock;
    }

    function claim(address to) external override {
        rewardToken.transfer(to, rewards[to]);
    }

    function onUnstake(uint, address to, uint blocksStaked) external override {
        rewardToken.transfer(to, rewardPerBlock * blocksStaked);
    }
}
