// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721, IERC721, ERC721Wrapper} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ITop3Rewards} from "../interfaces/ITop3Rewards.sol";

contract RewardVault is ERC721Wrapper {
    IERC20 private rewardToken;
    ITop3Rewards private rewarder;
    uint public numStaked;
    mapping(uint tokenId => uint stakedAt) private roundStaked;

    constructor(
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        ITop3Rewards _rewarder,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) ERC721Wrapper(underlyingToken) {
        rewardToken = _rewardToken;
        rewarder = _rewarder;
    }

    function _mint(address to, uint tokenId) internal virtual override {
        roundStaked[tokenId] = rewarder.roundsResolved();
        numStaked++;
        super._mint(to, tokenId);
    }

    function _burn(uint tokenId) internal virtual override {
        numStaked--;
        uint stakedAt = roundStaked[tokenId];
        delete roundStaked[tokenId];
        super._burn(tokenId);
        rewardToken.transfer(
            ownerOf(tokenId),
            rewarder.roundStakerReward() *
                (rewarder.roundsResolved() - stakedAt)
        );
    }
}
