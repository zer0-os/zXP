// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ILevelCurve} from "./interfaces/ILevelCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/Math.sol";

contract LinearLevelCurve is ILevelCurve {
    uint private intercept;
    uint private coefficient;
    uint256[] private thresholds;
    mapping(uint threshold => Function curve) private curves;

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

    function xpRequired(uint256 level) public view override returns (uint256) {
        return coefficient * level;
    }

    function levelAt(uint xp) external view override returns (uint) {
        return xp / coefficient;
    }
}
