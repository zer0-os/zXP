// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ILevelCurve} from "./interfaces/ILevelCurve.sol";

contract LevelCurve is ILevelCurve {
    uint256[] private levelThresholds;
    uint256 private constant COEFFICIENT = 1000;

    constructor(uint256[] memory _initialThresholds) {
        levelThresholds = _initialThresholds;
    }

    function getXPForLevel(
        uint256 level
    ) public view override returns (uint256) {
        require(level > 0, "Level must be greater than 0");
        uint256 xpRequired;
        if (level < levelThresholds.length) {
            xpRequired = levelThresholds[level - 1];
        } else {
            xpRequired = COEFFICIENT * level * level; // Example of a quadratic growth rate for higher levels
        }
        return xpRequired;
    }
}
