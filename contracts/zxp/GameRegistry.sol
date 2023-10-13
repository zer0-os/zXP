// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "./interfaces/IGameRegistry.sol";

contract GameRegistry is IGameRegistry {
    mapping(bytes32 game => address owner) public gameOwner;
    mapping(bytes32 game => mapping(bytes32 name => address object))
        public gameObjects;

    modifier onlyGameOwner(bytes32 game, address owner) {
        require(owner == gameOwner[game], "ZXP: Not game owner");
        _;
    }

    function createGame(bytes32 name, address owner) external override {
        gameOwner[name] = owner;
    }

    function registerObject(
        bytes32 game,
        bytes32 objectName,
        address objectAddress
    ) external override onlyGameOwner(game, msg.sender) {
        require(objectName.length > 0, "ZXP: No name");
        gameObjects[game][objectName] = objectAddress;
    }

    function addressOf(
        bytes32 game,
        bytes32 objectName
    ) external override returns (address) {
        return gameObjects[game][objectName];
    }
}
