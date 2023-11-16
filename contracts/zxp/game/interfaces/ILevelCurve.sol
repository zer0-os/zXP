// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILevelCurve {
    function getXPForLevel(uint level) external view returns (uint256);

    function getLevelForXP(uint xp) external view returns (uint256);
}
