// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XP is ERC20, GameRegistryClient {
    constructor(
        IGameRegistry registry,
        bytes32 game,
        string memory name,
        string memory symbol
    ) GameRegistryClient(registry, game) ERC20(name, symbol) {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual override {
        require(from == address(0) || to == address(0), "Token is soulbound");
        super._beforeTokenTransfer(from, to, amount);
    }
}
