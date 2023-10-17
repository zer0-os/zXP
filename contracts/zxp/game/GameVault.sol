// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721, IERC721, ERC721Wrapper} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IGameVault} from "./interfaces/IGameVault.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";

contract GameVault is ERC721Wrapper, Ownable, IGameVault, GameRegistryClient {
    bytes32 internal constant SEASON_REGISTRY = "SeasonRegistry";
    IERC20 private rewardToken;
    uint public numStaked;
    mapping(uint season => uint rewards) public seasonRewards;

    constructor(
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) ERC721Wrapper(underlyingToken) {
        rewardToken = _rewardToken;
        Ownable(msg.sender);
    }

    function claimRewards(
        address to,
        uint season
    ) external override only(SEASON_REGISTRY) {
        rewardToken.transfer(to, seasonRewards[season]);
    }
}