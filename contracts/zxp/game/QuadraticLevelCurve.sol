// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IQuadraticLevelCurve} from "./interfaces/IQuadraticLevelCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract QuadraticLevelCurve is IQuadraticLevelCurve {
    uint private coefficient = 100;

    function xpRequired(uint256 level) public view override returns (uint256) {
        return coefficient * level * level;
    }

    function levelAt(uint xp) external view override returns (uint) {
        return Math.sqrt(xp / coefficient);
    }
}
