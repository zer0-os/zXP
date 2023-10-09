// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IRewardVault} from "../interfaces/IRewardVault.sol";
import {ITop3Rewards} from "../interfaces/ITop3Rewards.sol";
import {ITop3Season} from "../interfaces/ITop3Season.sol";

contract Top3Rewards is Ownable, ITop3Rewards {
    IERC20 public rewardToken;
    IERC721 public stakedToken;
    ITop3Season public seasonManager;
    address public rewardVault;
    address public official;
    uint public maxRounds;
    uint private roundLength;
    uint private roundFirstAward;
    uint private roundSecondAward;
    uint private roundThirdAward;
    uint public roundStakerAward;
    uint private startTime;
    uint public roundsResolved;
    mapping(address player => uint winnings) public playerWinnings;

    constructor(address _official, address _vault) {
        Ownable(_official);
        rewardVault = _vault;
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
        startTime = block.timestamp;
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
        rewardToken.transfer(rewardVault, roundStakerAward);
    }

    function removeTokens(
        IERC20 token,
        address to
    ) external override onlyOwner {
        token.transfer(to, token.balanceOf(address(this)));
    }
}
