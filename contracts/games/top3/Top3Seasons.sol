// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ITop3Seasons} from "./interfaces/ITop3Seasons.sol";
import {Top3Rewards} from "./mechanics/Top3Rewards.sol";
import {RewardVault} from "./mechanics/RewardVault.sol";

contract Top3Season is Ownable, ITop3Season, IERC721Receiver {
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
        offSeason = true;
        rewardToken = _rewardToken;
        rewarder = new Top3Rewards(official);
        vault = new RewardVault(
            underlyingToken,
            rewardToken,
            rewarder,
            name,
            symbol
        );
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
        rewarder.removeTokens(owner());
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        IERC721(msg.sender).safeTransferFrom(
            address(this),
            address(vault),
            tokenId
        );
    }
}
