// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IObjectRegistry} from "../interfaces/IObjectRegistry.sol";
import {ObjectRegistryClient} from "../ObjectRegistryClient.sol";
import {QuadraticLevelCurve} from "./QuadraticLevelCurve.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IXP} from "./interfaces/IXP.sol";


// where is QuadraticLevelCurve logic used here? why do we inherit it?
contract XP is ObjectRegistryClient, QuadraticLevelCurve, ERC20, IXP {
    bytes32 internal constant SEASONS = "Seasons";

    constructor(
        string memory name,
        string memory symbol,
        IObjectRegistry registry,
        // why is this passed if it's not used?
        bytes32 game
    ) ObjectRegistryClient(registry) ERC20(name, symbol) {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual override {
        // does this need to support burning and minting? is that why it checks for `from` and `to`?
        // can minting be even done through transfer()? if not, then do we need `from` check?
        // could it just be a single `revert("ZXP: Token soulbound")`?
        // or it may even be on `transfer()` method instead of `_beforeTokenTransfer()`
        require(from == address(0) || to == address(0), "ZXP: Token soulbound");
        super._beforeTokenTransfer(from, to, amount);
    }

    // does this mean this will not work if Seasons contract is not used?
    function awardXP(address to, uint amount) external override only(SEASONS) {
        _mint(to, amount);
    }
}
