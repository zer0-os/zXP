// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILevelCurve {
    function xpRequired(uint level) external view returns (uint256);

    function levelAt(uint xp) external view returns (uint256);

    function testLine(uint x) external;
    function testQuad(uint x) external;
    function testSqrt(uint256 x) external;
    function testLog(uint x) external;
}
