// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "./interfaces/IGameRegistry.sol";

contract GameRegistry is IGameRegistry {
    struct Game {
        address owner;
        string description;
        mapping(bytes32 objectName => address objectAddress) objects;
    }
    mapping(bytes32 name => Game game) public games;

    modifier onlyGameOwner(bytes32 game, address owner) {
        require(isGameOwner(game, owner), "ZXP: Not game owner");
        _;
    }

    function createGame(
        bytes32 name,
        address owner,
        string calldata description,
        bytes32[] objectNames,
        address[] objectAddresses
    ) external override {
        games[name] = Game(owner, description);
        registerObjects(objectNames, objectAddresses);
    }

    function registerObjects(
        bytes32 game,
        bytes32[] objectNames,
        address[] objectAddresses
    ) external override onlyGameOwner(game, msg.sender) {
        require(objectNames.length > 0, "ZXP: Objects empty");
        for (uint256 i = 0; i < objectNames.length; i++) {
            games[name].objects[objectNames[i]] = objectAddresses[i];
        }
    }

    function isGameOwner(
        bytes32 game,
        address owner
    ) external override returns (bool) {
        return owner == games[game].owner;
    }

    function addressOf(
        bytes32 game,
        bytes32 objectName
    ) external override returns (address) {
        return gameObjects[game][objectName];
    }
}
