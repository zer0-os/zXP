// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IQuadraticLevelCurve {
    function xpRequired(uint level) external view returns (uint256);

    function levelAt(uint xp) external view returns (uint256);
}