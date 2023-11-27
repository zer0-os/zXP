// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../interfaces/IGameRegistry.sol";
import {GameRegistryClient} from "../GameRegistryClient.sol";
import {ILevelCurve} from "./interfaces/ILevelCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract LevelCurve is ILevelCurve {
    using Math for uint256;

    uint public test;
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
        coefficient = initialCoefficient;
        intercept = initialIntercept;
    }

    function xpRequired(
        uint256 level
    ) public view override returns (uint256) {
        require(level > 0, "Level must be greater than 0");
        return quadratic(level, 0, 0);
    }

    function levelAt(uint xp) external view override returns (uint){
        return xp;
    }

    function quadratic(uint x, uint xOffset, uint yOffset) internal view returns (uint) {
        return coefficient * (x - xOffset) * (x - xOffset) + yOffset;
    }

    function linear(uint x, uint xOffset, uint yOffset) internal view returns (uint) {
        return coefficient * (x - xOffset) + yOffset;
    }

    function testLine(uint x) public override{
        test = linear(x, 0, 0);
    }
    function testQuad(uint x) external override{
        test = quadratic(x, 0, 0);
    }
    function testSqrt(uint256 x) public override {
        test = Math.sqrt(x);
    }
    function testLog(uint x) external override{
        test = Math.log2(x);
    }
}
