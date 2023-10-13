// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISeasonRegistry {
    function mechanic(
        uint256 season,
        bytes32 name
    ) external view returns (address);

    function registerMechanic(
        uint season,
        bytes32 name,
        address mechanicAddress
    ) external;

    function startSeason(uint season) external;

    function endSeason(uint season) external;
}
