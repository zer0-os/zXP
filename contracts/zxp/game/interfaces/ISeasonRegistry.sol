// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISeasonRegistry {
    struct Season {
        string description;
        uint start;
        uint end;
        mapping(bytes32 name => address mechanicAddress) mechanics;
    }

    function addressOf(
        uint256 season,
        bytes32 name
    ) external view returns (address);

    function registerMechanic(
        uint season,
        bytes32[] calldata mechanicNames,
        address[] calldata mechanicAddresses
    ) external;

    function initializeNextSeason(string calldata description) external;

    function startSeason(uint season) external;

    function endSeason(uint season) external;
}
