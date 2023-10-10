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
    uint private roundFirstAward;
    uint private roundSecondAward;
    uint private roundThirdAward;
    uint public roundStakerAward;
    uint public roundsResolved;
    mapping(address player => uint winnings) public playerWinnings;

    constructor(IERC20 _rewardToken) {
        Ownable(msg.sender);
        seasons = ITop3Seasons(msg.sender);
        rewardToken = _rewardToken;
    }

    function claimWinnings() external override {
        rewardToken.transfer(msg.sender, playerWinnings[msg.sender]);
    }

    function startSeason(
        uint _maxRounds,
        uint _roundFirstReward,
        uint _roundSecondReward,
        uint _roundThirdReward,
        uint _roundStakerReward
    ) external override onlyOwner {
        maxRounds = _maxRounds;
        roundFirstAward = _roundFirstReward;
        roundSecondAward = _roundSecondReward;
        roundThirdAward = _roundThirdReward;
        roundStakerAward = _roundStakerReward;
    }

    function submitTop3Results(
        address first,
        address second,
        address third
    ) external override onlyOwner {
        require(roundsResolved < maxRounds, "Top3 max rounds exceeded");
        roundsResolved++;
        playerWinnings[first] += roundFirstAward;
        playerWinnings[second] += roundSecondAward;
        playerWinnings[third] += roundThirdAward;
        rewardToken.transfer(seasons.vaultAddress(), roundStakerAward);
    }

    function test() external view returns (address) {
        return seasons.vaultAddress();
    }

    function finalizeSeason() external override onlyOwner {
        roundsResolved = 0;
        if (rewardToken.balanceOf(address(this)) != 0) {
            rewardToken.transfer(owner(), rewardToken.balanceOf(address(this)));
        }
    }
}
