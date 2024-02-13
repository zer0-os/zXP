// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IObjectRegistry } from "./interfaces/IObjectRegistry.sol";


/**
 * @dev Base contract for Registry clients
 */
contract ObjectRegistryClient {
    IObjectRegistry public registry; // address of the registry

    /**
     * @dev verifies that the caller is mapped to the given contract name
     *
     * @param object registered object
     */
    modifier only(bytes32 object) {
        _only(object);
        _;
    }

    // error message binary size optimization
    function _only(bytes32 object) internal view {
        require(msg.sender == registry.addressOf(object), "ZXP: Access denied");
    }

    /**
     * @dev initializes a new ContractRegistryClient instance
     *
     * @param  objectRegistry   address of a contract-registry contract
     */
    constructor(IObjectRegistry objectRegistry) {
        registry = objectRegistry;
    }
}
