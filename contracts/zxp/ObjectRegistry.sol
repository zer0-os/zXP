// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IObjectRegistry} from "./interfaces/IObjectRegistry.sol";

contract ObjectRegistry is IObjectRegistry {
    bytes32 internal constant OWNER = "Owner"; // maybe put all constants in a library?

    // bytes mapping of "name" to registry address of that specific object type
    mapping(bytes32 name => address object) public objects;

    constructor(address owner) {
        objects[OWNER] = owner;
    }

    function registerObjects(
        bytes32[] calldata objectNames,
        address[] calldata objectAddresses
    ) public override {
        // ZXP specific object inside of generic "registry" contract object
        require(msg.sender == objects[OWNER], "ZXP Not game owner");
        require(objectNames.length > 0, "ZXP Objects empty");
        for (uint256 i = 0; i < objectNames.length; i++) {
            objects[objectNames[i]] = objectAddresses[i];
        }
    }

    function addressOf(
        bytes32 objectName
    ) external view override returns (address) {
        return objects[objectName];
    }
}
