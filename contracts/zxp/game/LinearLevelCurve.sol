// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ILinearLevelCurve} from "./interfaces/ILinearLevelCurve.sol";

contract LinearLevelCurve is ILinearLevelCurve {
    uint private yIntercept;
    uint private coefficient;

    constructor(uint initialCoefficient, uint initialIntercept) {
        coefficient = initialCoefficient;
        yIntercept = initialIntercept;
    }

    function xpRequired(uint256 level) public view override returns (uint256) {
        return coefficient * level + yIntercept;
    }

    function levelAt(uint xp) external view override returns (uint) {
        return xp / coefficient + yIntercept;
    }
}
