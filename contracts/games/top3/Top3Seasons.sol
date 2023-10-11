// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ITop3Seasons} from "./interfaces/ITop3Seasons.sol";
import {Top3Rewards} from "./mechanics/Top3Rewards.sol";
import {RewardVault} from "./mechanics/RewardVault.sol";

contract Top3Seasons is Ownable, ITop3Seasons {
    uint public currentSeason;
    bool public offSeason;
    Top3Rewards public rewarder;
    RewardVault public vault;
    IERC20 public rewardToken;

    constructor(
        address official,
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        string memory name,
        string memory symbol
    ) {
        Ownable(official);
        offSeason = true;
        rewardToken = _rewardToken;
        rewarder = new Top3Rewards(rewardToken);
        vault = new RewardVault(
            underlyingToken,
            rewardToken,
            ITop3Seasons(this),
            rewarder,
            name,
            symbol
        );
        emit Deployed(address(vault), address(rewarder));
    }

    function startSeason(
        uint maxRounds,
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
            roundStakerReward / vault.numStaked()
        );
        rewardToken.transfer(
            address(rewarder),
            maxRounds *
                (roundFirstReward +
                    roundSecondReward +
                    roundThirdReward +
                    roundStakerReward)
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
        vault.finalizeSeason();
        rewarder.finalizeSeason();
    }

    function claimRewards(uint season) external override {
        vault.claimRewards(msg.sender, season);
        rewarder.claimRewards(msg.sender);
    }

    function vaultAddress() external view override returns (address) {
        return address(vault);
    }

    event Deployed(address vault, address rewards);
}
