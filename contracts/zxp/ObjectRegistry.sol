// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IObjectRegistry } from "./interfaces/IObjectRegistry.sol";


contract ObjectRegistry is IObjectRegistry {
    bytes32 internal constant OWNER = "Owner";
    // what is an object? is it a contract?
    // the name is too generic and is not clear what it is
    mapping(bytes32 name => address object) public objects;

    constructor(address owner) {
        objects[OWNER] = owner;
    }

    function registerObjects(
        bytes32[] calldata objectNames,
        address[] calldata objectAddresses
    ) public override {
        // does this work? if it comes from Games.createGame() then msg.sender is that contract and not the owner wallet.
        require(msg.sender == objects[OWNER], "ZXP Not game owner");
        // should we check that the length of both of these arrays are equal?
        // otherwise we can get wrong opcode error. but it can be a way to prevent passing arrays of different lengths...
        // need to test this
        require(objectNames.length > 0, "ZXP Objects empty");
        for (uint256 i = 0; i < objectNames.length; i++) {
            objects[objectNames[i]] = objectAddresses[i];
        }
    }

    function addressOf(
    // where are these names stored?
    // is it up to the owner of the game to store them somewhere off-chain?
        bytes32 objectName
    ) external view override returns (address) {
        return objects[objectName];
    }
}
