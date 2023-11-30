// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {IQuadraticLevelCurve} from "./interfaces/IQuadraticLevelCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract QuadraticLevelCurve is IQuadraticLevelCurve {
    uint private yIntercept;
    uint private coefficient;

    constructor(uint initialCoefficient, uint initialIntercept) {
        coefficient = initialCoefficient;
        yIntercept = initialIntercept;
    }

    function xpRequired(uint256 level) public view override returns (uint256) {
        return coefficient * level * level + yIntercept;
    }

    function levelAt(uint xp) external view override returns (uint) {
        return coefficient * Math.sqrt(xp) + yIntercept;
    }
}
