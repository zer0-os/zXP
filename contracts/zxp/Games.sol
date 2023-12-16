// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGames} from "./interfaces/IGames.sol";
import {ObjectRegistry} from "./ObjectRegistry.sol";

contract Games is IGames, ObjectRegistry {
    struct Game {
        string metadata;
        ObjectRegistry objects;
    }
    mapping(bytes32 name => Game game) public games;

    constructor() ObjectRegistry(msg.sender) {}

    function createGame(
        bytes32 name,
        address owner,
        string calldata metadata,
        bytes32[] calldata objectNames,
        address[] calldata objectAddresses
    ) external override {
        ObjectRegistry newRegistry = new ObjectRegistry(owner);
        games[name].metadata = metadata;
        games[name].objects = newRegistry;
        if (objectNames.length > 0) {
            newRegistry.registerObjects(objectNames, objectAddresses);
        }
    }
}
