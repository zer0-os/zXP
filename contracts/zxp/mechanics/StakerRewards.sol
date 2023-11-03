// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IStakerRewards} from "./interfaces/IStakerRewards.sol";
import {IGameVault} from "../game/interfaces/IGameVault.sol";

contract StakerRewards is IStakerRewards {
    IERC20 public rewardToken;
    uint public rewardPerBlock;
    IERC721 private underlyingToken;
    IGameVault private underlyingVault;
    mapping(address awardee => uint amount) public rewards;
    mapping(uint nft => uint block) public claimedAt;

    constructor(
        IERC20 erc20RewardToken,
        uint tokenRewardPerBlock,
        IERC721 nft,
        IGameVault vault
    ) {
        rewardToken = erc20RewardToken;
        rewardPerBlock = tokenRewardPerBlock;
        underlyingToken = nft;
        underlyingVault = vault;
    }

    function onUnstake(uint id, address to, uint stakedAt) external override {
        uint numBlocks;
        if (stakedAt < claimedAt[id]) {
            numBlocks = block.number - claimedAt[id];
        } else {
            numBlocks = block.number - stakedAt;
        }
        claimedAt[id] = block.number;
        rewardToken.transfer(to, rewardPerBlock * numBlocks);
    }

    function claim(uint id) external override {
        require(
            underlyingToken.ownerOf(id) == msg.sender,
            "ZXP claimer isnt owner"
        );
        uint numBlocks;
        if (underlyingVault.stakedAt(id) < claimedAt[id]) {
            numBlocks = block.number - claimedAt[id];
        } else {
            numBlocks = block.number - underlyingVault.stakedAt(id);
        }
        claimedAt[id] = block.number;
        rewardToken.transfer(msg.sender, rewardPerBlock * numBlocks);
    }
}