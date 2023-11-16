// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IXP {
    function awardXP(address to, uint amount) external;

    function getXPForLevel(uint level) external pure returns (uint);
}
