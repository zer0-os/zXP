// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721, IERC721, ERC721Wrapper} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ITop3Seasons} from "../interfaces/ITop3Seasons.sol";
import {ITop3Rewards} from "../interfaces/ITop3Rewards.sol";
import {IRewardVault} from "../interfaces/IRewardVault.sol";

contract RewardVault is ERC721Wrapper, Ownable, IRewardVault {
    IERC20 private rewardToken;
    ITop3Rewards private rewarder;
    ITop3Seasons private seasons;
    uint public numStaked;
    mapping(uint tokenId => mapping(uint season => uint stakedAt))
        private roundStaked;
    mapping(uint season => uint finalRewards) public seasonRewards;

    constructor(
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        ITop3Seasons _seasons,
        ITop3Rewards _rewarder,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) ERC721Wrapper(underlyingToken) {
        rewardToken = _rewardToken;
        rewarder = _rewarder;
        seasons = _seasons;
        Ownable(address(seasons));
    }

    function _mint(address to, uint tokenId) internal virtual override {
        roundStaked[seasons.currentSeason()][tokenId] = rewarder
            .roundsResolved();
        numStaked++;
        super._mint(to, tokenId);
    }

    function _burn(uint tokenId) internal virtual override {
        numStaked--;
        uint stakedAt = roundStaked[seasons.currentSeason()][tokenId];
        delete roundStaked[seasons.currentSeason()][tokenId];
        super._burn(tokenId);
        rewardToken.transfer(
            ownerOf(tokenId),
            rewarder.roundStakerAward() * (rewarder.roundsResolved() - stakedAt)
        );
    }

    function finalizeSeason() external override onlyOwner {
        seasonRewards[seasons.currentSeason()] =
            rewardToken.balanceOf(address(this)) /
            numStaked;
    }

    function claimRewards(address to, uint season) external override onlyOwner {
        rewardToken.transfer(to, seasonRewards[season]);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public virtual override returns (bytes4) {
        require(seasons.offSeason(), "ZXP season active");
        return super.onERC721Received(operator, from, tokenId, data);
    }
}
