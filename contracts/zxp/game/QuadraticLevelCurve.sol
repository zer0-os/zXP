// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ILevelCurve} from "./interfaces/ILevelCurve.sol";

contract QuadraticLevelCurve is ILevelCurve {
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
        return coefficient * level * level;
    }

    function levelAt(uint xp) external view override returns (uint) {
        return 1;//sqrt(xp);
    }
}
