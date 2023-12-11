// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IObjectRegistry} from "../interfaces/IObjectRegistry.sol";
import {ObjectRegistryClient} from "../ObjectRegistryClient.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IXP} from "./interfaces/IXP.sol";

contract XP is ERC20, ObjectRegistryClient, IXP {
    bytes32 internal constant SEASONS = "Seasons";

    constructor(
        string memory name,
        string memory symbol,
        IObjectRegistry registry,
        bytes32 game
    ) ObjectRegistryClient(registry) ERC20(name, symbol) {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual override {
        require(from == address(0) || to == address(0), "ZXP: Token soulbound");
        super._beforeTokenTransfer(from, to, amount);
    }

    function awardXP(address to, uint amount) external override only(SEASONS) {
        _mint(to, amount);
    }

    function getXPForLevel(
        uint256 level
    ) public pure override returns (uint256) {
        return 100 * level * level;
    }
}
