// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISeasonRegistry {
    function addressOf(
        uint256 season,
        bytes32 name
    ) external view returns (address);

    function registerMechanics(
        uint season,
        bytes32[] calldata mechanicNames,
        address[] calldata mechanicAddresses
    ) external;

    function startSeason() external;

    function endSeason() external;
}
