// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ITop3Seasons} from "../interfaces/ITop3Seasons.sol";
import {ITop3Rewards} from "../interfaces/ITop3Rewards.sol";

contract Top3Rewards is Ownable, ITop3Rewards {
    IERC20 public rewardToken;
    ITop3Seasons private seasons;
    uint public maxRounds;
    uint private roundLength;
    uint private roundFirstReward;
    uint private roundSecondReward;
    uint private roundThirdReward;
    uint public roundStakerReward;
    uint private totalRoundRewards;
    uint public roundsResolved;
    mapping(address player => uint winnings) public playerWinnings;

    constructor(IERC20 _rewardToken) {
        seasons = ITop3Seasons(msg.sender);
        rewardToken = _rewardToken;
        Ownable(address(seasons));
    }

    function claimRewards(address to) external override {
        rewardToken.transfer(to, playerWinnings[to]);
    }

    function startSeason(
        uint _maxRounds,
        uint _roundFirstReward,
        uint _roundSecondReward,
        uint _roundThirdReward,
        uint _roundStakerReward
    ) external override onlyOwner {
        maxRounds = _maxRounds;
        roundFirstReward = _roundFirstReward;
        roundSecondReward = _roundSecondReward;
        roundThirdReward = _roundThirdReward;
        roundStakerReward = _roundStakerReward;
        totalRoundRewards =
            roundFirstReward +
            roundSecondReward +
            roundThirdReward +
            roundStakerReward;
    }

    function submitTop3Results(
        address first,
        address second,
        address third
    ) external override onlyOwner {
        require(roundsResolved < maxRounds, "Top3 max rounds exceeded");
        roundsResolved++;
        playerWinnings[first] += roundFirstReward;
        playerWinnings[second] += roundSecondReward;
        playerWinnings[third] += roundThirdReward;
        rewardToken.transfer(seasons.vaultAddress(), roundStakerReward);
    }

    function finalizeSeason() external override onlyOwner {
        uint actualBalance = rewardToken.balanceOf(address(this)) -
            roundsResolved *
            totalRoundRewards;
        roundsResolved = 0;
        if (rewardToken.balanceOf(address(this)) != 0) {
            rewardToken.transfer(owner(), actualBalance);
        }
    }
}
