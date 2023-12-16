// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721, IERC721, ERC721Wrapper} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IGameVault} from "./interfaces/IGameVault.sol";
import {IObjectRegistry} from "../interfaces/IObjectRegistry.sol";
import {ObjectRegistryClient} from "../ObjectRegistryClient.sol";
import {ISeasons} from "./interfaces/ISeasons.sol";

contract GameVault is ERC721Wrapper, IGameVault, ObjectRegistryClient {
    bytes32 internal constant SEASONS = "Seasons";
    mapping(uint id => uint block) public stakedAt;

    constructor(
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        string memory name,
        string memory symbol,
        IObjectRegistry registry,
        bytes32 game
    )
        ObjectRegistryClient(registry)
        ERC721(name, symbol)
        ERC721Wrapper(underlyingToken)
    {}

    function _mint(address to, uint id) internal override {
        stakedAt[id] = block.number;
        super._mint(to, id);
    }

    function _burn(uint id) internal override {
        ISeasons(registry.addressOf(SEASONS)).onUnstake(
            id,kjjb
            msg.sender,
            block.number - stakedAt[id]
        );
        stakedAt[id] = 0;
        super._burn(id);
    }
}
