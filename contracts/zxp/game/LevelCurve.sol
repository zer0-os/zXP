// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ILevelCurve} from "./interfaces/ILevelCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract LevelCurve is ILevelCurve {
    using Math for uint;

    uint private intercept;
    uint private coefficient;
    uint256[] private thresholds;
    mapping(uint threshold => Function curve) private curves;

    enum Function {
        CONSTANT,
        LINEAR,
        QUADRATIC,
        LOGARITHMIC
    }

    constructor(
        uint256[] memory initialThresholds,
        Function[] memory initialCurves,
        uint initialCoefficient,
        uint initialIntercept
    ) {
        require(
            initialThresholds.length == initialCurves.length,
            "Thresholds and curves length must be equal"
        );
        thresholds = initialThresholds;
        coefficient = initialCoefficient;
        intercept = initialIntercept;
        for (uint256 i = 0; i < initialThresholds.length; i++) {
            curves[initialThresholds[i]] = initialCurves[i];
        }
    }

    function xpRequired(uint256 level) public view override returns (uint256) {
        require(level > 0, "Level must be greater than 0");
        return quadratic(level, 0, 0);
    }

    function levelAt(uint xp) external view override returns (uint) {
        return coefficient * xp;
    }

    function quadratic(
        uint x,
        uint xOffset,
        uint yOffset
    ) internal view returns (uint) {
        return coefficient * (x - xOffset) * (x - xOffset) + yOffset;
    }

    function linear(
        uint x,
        uint xOffset,
        uint yOffset
    ) internal view returns (uint) {
        return coefficient * (x - xOffset) + yOffset;
    }
}
