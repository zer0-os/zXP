// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISeasons {
    function startSeason() external;

    function endSeason() external;

    function onUnstake(uint id, address to, uint blocks) external;
}
