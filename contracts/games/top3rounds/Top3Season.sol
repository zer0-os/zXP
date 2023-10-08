// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ITop3Season} from "./interfaces/ITop3Season.sol";
import {Top3Rewards} from "./mechanics/Top3Rewards.sol";
import {RewardVault} from "./mechanics/RewardVault.sol";

contract Top3Season is Ownable, ISeason {
    uint public currentSeason;
    bool public offSeason;
    Top3Rewards public rewarder;
    RewardVault public vault;

    constructor(
        address official,
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        string memory name,
        string memory symbol
    ) {
        offSeason = true;
        vault = new RewardVault(
            underlyingToken,
            _rewardToken,
            _rearder,
            name,
            symbol
        );
        rewarder = new Top3Rewards(official);
    }

    function startSeason(
        uint roundFirstReward,
        uint roundSecondReward,
        uint roundThirdReward,
        uint roundStakerReward
    ) external override onlyOwner {
        require(offSeason, "ZXP season active");
        currentSeason++;
        offSeason = false;
        rewarder.startSeason(
            maxRounds,
            roundFirstReward,
            roundSecondReward,
            roundThirdReward,
            roundStakerReward
        );
        rewardToken.transfer(
            address(rewarder),
            vault.numStaked() *
                roundStakerReward +
                maxRounds *
                (roundFirstAward + roundSecondAward + roundThirdAward)
        );
    }

    function resolveRound(
        address first,
        address second,
        address third
    ) external override {
        rewarder.submitTop3Results(first, second, third);
    }

    function endSeason() external override onlyOwner {
        require(!offSeason, "ZXP offseason");
        offSeason = true;
        rewarder.removeTokens(owner());
    }
}
