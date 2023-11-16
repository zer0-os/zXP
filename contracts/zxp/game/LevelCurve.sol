// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ILevelCurve} from "./interfaces/ILevelCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/Math.sol";

contract LevelCurve is ILevelCurve {
    uint private intercept;
    uint private coefficient;
    uint256[] private thresholds;
    mapping(uint threshold => Function curve) private curves;

    enum Function {
        CONSTANT,
        LINEAR,
        QUADRATIC,
        LOGARITHMIC,
    }

    constructor(
        uint256[] memory initialThresholds,
        uint256[] memory initialCurves,
        uint initialCoefficient,
        uint initialIntercept
    ) {
        thresholds = initialThresholds;
        curves = initialCurves;
        coefficient = initialCoefficient;
        intercept = initialIntercept;
    }

    function getXPForLevel(
        uint256 level
    ) public view override returns (uint256) {
        require(level > 0, "Level must be greater than 0");
        uint256 xpRequired;
        if (level < levelThresholds.length) {
            xpRequired = levelThresholds[level - 1];
        } else {
            xpRequired = coefficient * level * level; // Example of a quadratic growth rate for higher levels
        }
        return xpRequired;
    }

    function quadratic(uint x, uint origin) internal view returns (uint) {
        return coefficient * (x - origin) * (x - origin) + intercept;
    }

    function linear(uint x, uint origin) internal view returns (uint) {
        return coefficient * (x - origin) + intercept;
    }
}
