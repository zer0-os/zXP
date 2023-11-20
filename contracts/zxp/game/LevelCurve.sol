// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ILevelCurve} from "./interfaces/ILevelCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract LevelCurve is ILevelCurve {
    using Math for uint256;

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
        uint256[] memory initialCurves,
        uint initialCoefficient,
        uint initialIntercept
    ) {
        thresholds = initialThresholds;
        //curves = initialCurves;
        coefficient = initialCoefficient;
        intercept = initialIntercept;
    }

    function xpRequired(
        uint256 level
    ) public view override returns (uint256) {
        require(level > 0, "Level must be greater than 0");
        uint256 xpRequired;
        if (level < thresholds.length) {
            xpRequired = thresholds[level - 1];
        } else {
            xpRequired = coefficient * level * level; // Example of a quadratic growth rate for higher levels
        }
        return xpRequired;
    }

    function levelAt(uint xp) external view override returns (uint){
        //(uint, uint xOffset, uint) = getCurve()
        return 1; //Math.sqrt(xp-xOffset) + yOffset;
    }
/*
    function getCurve(uint level) internal view override returns (uint, uint, uint){
        if(xp >= thresholds[thesholds.length - 1]){}
    }
*/
    function quadratic(uint x, uint xOffset, uint yOffset) internal view returns (uint) {
        return coefficient * (x - xOffset) * (x - xOffset) + yOffset;
    }

    function linear(uint x, uint xOffset, uint yOffset) internal view returns (uint) {
        return coefficient * (x - xOffset) + yOffset;
    }
}