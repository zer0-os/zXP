// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721, IERC721, ERC721Wrapper} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IGameVault} from "./interfaces/IGameVault.sol";
import {IObjectRegistry} from "../interfaces/IObjectRegistry.sol";
import {ObjectRegistryClient} from "../ObjectRegistryClient.sol";
import {ISeasons} from "./interfaces/ISeasons.sol";

contract GameVault is ERC721Wrapper, ObjectRegistryClient, IGameVault {
    bytes32 internal constant SEASONS = "Seasons";
    // TODO should be nested mapping to include which user staked it, maybe
    // Depends on if we want to allow the game vault token to be transferable?
    mapping(uint id => uint block) public stakedAt;

    constructor(
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        string memory stakedTokenName, ///name of tokens that this contract issues on stake of underlyingToken
        string memory stakedTokenSymbol, ///symbol of tokens that this contract issues on stake of underlyingToken
        IObjectRegistry registry,
        bytes32 game // unused
    )
        ObjectRegistryClient(registry)
        ERC721(stakedTokenName, stakedTokenSymbol)
        ERC721Wrapper(underlyingToken)
    {}

    function _mint(address to, uint id) internal override {
        stakedAt[id] = block.number;
        super._mint(to, id);
    }

    function _burn(uint id) internal override {
        uint wasStakedAt = stakedAt[id];
        stakedAt[id] = 0;
        ISeasons(registry.addressOf(SEASONS)).onUnstake(
            id,
            msg.sender,
            block.number - wasStakedAt
            // TODO param expects just `stakedAt[i]` not `block.number - stakedAt[i]`
        );
        super._burn(id);
    }
}
