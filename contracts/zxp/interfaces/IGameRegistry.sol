// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGameRegistry {
    function createGame(bytes32 name, address owner) external;

    function registerObject(
        bytes32 name,
        bytes32[] calldata objectNames,
        address[] calldata objectAddresses
    ) external;
 
    function addressOf(
        bytes32 game,
        bytes32 objectName
    ) external returns (address)
}
