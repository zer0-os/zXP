// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721, IERC721, ERC721Wrapper} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ITop3Award} from "./interfaces/ITop3Award.sol";

contract RewardVault is ERC721Wrapper {
    IERC20 private awardToken;
    ITop3Award private awarder;
    uint private numStaked;
    mapping(uint tokenId => uint stakedAt) private roundStaked;

    constructor(
        IERC721 underlyingToken,
        IERC20 _awardToken,
        ITop3Award _awarder,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) ERC721Wrapper(underlyingToken) {
        awardToken = _awardToken;
        awarder = _awarder;
    }

    function _mint(address to, uint tokenId) internal virtual override {
        roundStaked[tokenId] = awarder.roundsResolved();
        numStaked++;
        super._mint(to, tokenId);
    }

    function _burn(uint tokenId) internal virtual override {
        numStaked--;
        roundStaked[tokenId] = 0;
        super._burn(tokenId);
        awardToken.transfer(
            ownerOf(tokenId),
            awarder.roundStakerAward() *
                (awarder.roundsResolved() - roundStaked[tokenId])
        );
    }
}
