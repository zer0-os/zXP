// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "./interfaces/IGameRegistry.sol";

contract GameRegistry is IGameRegistry {
    struct Game {
        address owner;
        string description;
        mapping(bytes32 objectName => address objectAddress) objects;
    }
    mapping(bytes32 gameName => Game game) public games;

    modifier onlyGameOwner(bytes32 game, address owner) {
        require(owner == games[game].owner, "ZXP: Not game owner");
        _;
    }

    function createGame(
        bytes32 name,
        address owner,
        string calldata description,
        address[] objects
    ) external override {
        games[name].owner = owner;
        games[name].description = description;
        games[name].objects = objects;
    }

    function registerObject(
        bytes32 game,
        bytes32 objectName,
        address objectAddress
    ) external override onlyGameOwner(game, msg.sender) {
        require(objectName.length > 0, "ZXP: No name");
        games[game].gameObjects[objectName] = objectAddress;
    }

    function addressOf(
        bytes32 game,
        bytes32 objectName
    ) external override returns (address) {
        return gameObjects[game][objectName];
    }
}
