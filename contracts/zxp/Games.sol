// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IGames } from "./interfaces/IGames.sol";
import { ObjectRegistry } from "./ObjectRegistry.sol";


// why does this need to be ObjectRegistry? where is this functionality used?
// mb also change the inheritance order. go with interface last
contract Games is IGames, ObjectRegistry {
    struct Game {
        string metadata;
        // this should be named better. it's confusing what this is
        ObjectRegistry objects;
    }

    mapping(bytes32 name => Game game) public games;

    constructor() ObjectRegistry(msg.sender) {}

    function createGame(
        bytes32 name,
        // why is this not an msg.sender? to set someone else as an owner?
        address owner,
        string calldata metadata,
        // who deploys these contracts and who pays for each deployment of
        // these sets of objects per EVERY game?
        bytes32[] calldata objectNames,
        address[] calldata objectAddresses
    ) external override {
        // what is the difference between this ObjectRegistry and the one we inherited here, initialized in the constructor?
        // also, does there HAVE to be a new registry for every game?
        // what are the advantages of this?
        ObjectRegistry newRegistry = new ObjectRegistry(owner);
        games[name].metadata = metadata;
        games[name].objects = newRegistry;
        if (objectNames.length > 0) {
            // this call will always fail because msg.sender is the contract and not the owner
            // that is set above on L31
            // this is also never tested, and it seems to be a crucial function
            newRegistry.registerObjects(objectNames, objectAddresses);
        }
    }
}
