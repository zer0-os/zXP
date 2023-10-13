// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITop3Seasons {
    function startSeason(uint, uint, uint, uint, uint) external;

    function resolveRound(address, address, address) external;

    function endSeason() external;

    function claimRewards(uint) external;

    function currentSeason() external view returns (uint);

    function offSeason() external view returns (bool);

    function vaultAddress() external view returns (address);
}
