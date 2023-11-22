// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ILevelCurve} from "./interfaces/ILevelCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract Log2LevelCurve is ILevelCurve {
    using Math for uint256;

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
        return coefficient * Math.log2(level);
    }

    function levelAt(uint256 xp) external view override returns (uint) {
        return coefficient * xp * xp;
    }
}
