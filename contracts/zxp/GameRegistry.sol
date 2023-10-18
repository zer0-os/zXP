// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "./interfaces/IGameRegistry.sol";

contract GameRegistry is IGameRegistry {
    bytes32 internal constant OWNER = "Owner";
    struct Game {
        string metadata;
        mapping(bytes32 objectName => address objectAddress) objects;
    }
    mapping(bytes32 name => Game game) public games;

    function createGame(
        bytes32 name,
        address owner,
        string calldata metadata,
        bytes32[] calldata objectNames,
        address[] calldata objectAddresses
    ) external override {
        games[name].metadata = metadata;
        games[name].objects[OWNER] = owner;
        registerObjects(name, objectNames, objectAddresses);
    }

    function registerObjects(
        bytes32 game,
        bytes32[] calldata objectNames,
        address[] calldata objectAddresses
    ) public override {
        require(msg.sender == games[game].objects[OWNER], "ZXP not game owner");
        require(objectNames.length > 0, "ZXP: Objects empty");
        for (uint256 i = 0; i < objectNames.length; i++) {
            games[game].objects[objectNames[i]] = objectAddresses[i];
        }
    }

    function addressOf(
        bytes32 game,
        bytes32 objectName
    ) external view override returns (address) {
        return games[game].objects[objectName];
    }
}
