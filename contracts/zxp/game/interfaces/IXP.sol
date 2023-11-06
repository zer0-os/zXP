// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILevelCurve {
    function awardXP(address to, uint amount) external view returns (uint256);
}
