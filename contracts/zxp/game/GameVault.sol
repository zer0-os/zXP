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
    mapping(uint id => uint block) public stakedAt;

    constructor(
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        string memory underlyingTokenName,
        string memory underlyingTokenSymbol,
        IObjectRegistry registry,
        bytes32 game
    )
        ObjectRegistryClient(registry)
        ERC721(underlyingTokenName, underlyingTokenSymbol)
        ERC721Wrapper(underlyingToken)
    {}

    // what is this `id` for? how do we get it? maybe a clearer name?
    function _mint(address to, uint id) internal override {
        stakedAt[id] = block.number;
        super._mint(to, id);
    }

    function _burn(uint id) internal override {
        // moved this for checks-effects pattern to avoid reentrancy
        uint stakedAt = stakedAt[id];
        stakedAt[id] = 0;

        ISeasons(registry.addressOf(SEASONS)).onUnstake(
            id,
            msg.sender,
            block.number - stakedAt
        );
        super._burn(id);
    }
}
