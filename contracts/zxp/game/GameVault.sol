// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721, IERC721, ERC721Wrapper} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Wrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IGameVault} from "./interfaces/IGameVault.sol";
import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ISeasonRegistry} from "./interfaces/ISeasonRegistry.sol";

contract GameVault is ERC721Wrapper, IGameVault, GameRegistryClient {
    mapping(uint id => uint block) public stakedAt;

    constructor(
        IERC721 underlyingToken,
        IERC20 _rewardToken,
        string memory name,
        string memory symbol,
        IGameRegistry registry,
        bytes32 game
    )
        GameRegistryClient(registry, game)
        ERC721(name, symbol)
        ERC721Wrapper(underlyingToken)
    {}
    /*
    function safeMint(address to, uint256 id) public override {
        stakedAt[id] = block.number;
        super.safeMint(to, id);
    }

    function burn(uint256 id) public override {
        ISeasonRegistry(registry.addressOf(game, SEASON_REGISTRY)).onUnstake(
            id,
            msg.sender,
            block.number - stakedAt[id]
        );
        stakedAt[id] = 0;
        super.burn(id);
    }*/
}
