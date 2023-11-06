// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILevelCurve {
    function getXPForLevel(uint256 level) external view returns (uint256);
}
