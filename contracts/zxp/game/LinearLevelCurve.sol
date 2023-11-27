// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ILinearLevelCurve} from "./interfaces/ILinearLevelCurve.sol";

contract LinearLevelCurve is ILinearLevelCurve {
    uint private intercept;
    uint private coefficient;

    constructor(
        uint initialCoefficient,
        uint initialIntercept
    ) {
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
