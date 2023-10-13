// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GameRegistry is IGameRegistry {
    mapping(bytes32 game => address[] objects) gameObjects;

    ///contract names are limited to 32 bytes UTF8 encoded ASCII strings to optimize gas costs
    function registerObject(
        bytes32 objectName,
        address objectAddress
    ) public ownerOnly validAddress(_contractAddress) {
        require(_contractName.length > 0, "ERR_INVALID_NAME");

        // update the address in the registry
        gameObjects[objectName][objectAddress] = objectAddress;
    }
}
