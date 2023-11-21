// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IXP} from "./interfaces/IXP.sol";

contract XP is ERC20, GameRegistryClient, IXP {
    constructor(
        string memory name,
        string memory symbol,
        IGameRegistry registry,
        bytes32 game
    ) GameRegistryClient(registry, game) ERC20(name, symbol) {}
    
    /*
    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual override {
        require(from == address(0) || to == address(0), "ZXP: Token soulbound");
        super._beforeTokenTransfer(from, to, amount);
    }*/

    function awardXP(
        address to,
        uint amount
    ) external override only(SEASON_REGISTRY) {
        _mint(to, amount);
    }

    function getXPForLevel(
        uint256 level
    ) public pure override returns (uint256) {
        return 100 * level * level;
    }
}
