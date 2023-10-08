// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITop3Season {
    function startSeason(uint, uint, uint, uint) external;

    function resolveRound(address, address, address) external;

    function endSeason() external;

    function currentSeason() external view returns (uint);

    function offSeason() external view returns (bool);
}
