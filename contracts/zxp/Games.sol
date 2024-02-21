// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGames} from "./interfaces/IGames.sol";
import {ObjectRegistry} from "./ObjectRegistry.sol";

contract Games is IGames {
    struct Game {
        string metadata;
        ObjectRegistry gameObjects;
    }
    mapping(bytes32 name => Game game) public games;

    function createGame(
        bytes32 name,
        address owner,
        string calldata metadata
    ) external override {
        ObjectRegistry newRegistry = new ObjectRegistry(owner);
        games[name].metadata = metadata;
        games[name].gameObjects = newRegistry;
    }
}
