// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGameRegistry} from "./IGameRegistry.sol";

/**
 * @dev Base contract for Registry clients
 */
contract GameRegistryClient is IGameRegistryClient {
    IGameRegistry public registry; // address of the registry

    /**
     * @dev verifies that the caller is mapped to the given contract name
     *
     * @param _contractName    contract name
     */
    modifier only(bytes32 name) {
        _only(name);
        _;
    }

    // error message binary size optimization
    function _only(bytes32 game, bytes32 object) internal view {
        require(msg.sender == addressOf(game, object), "ZXP: Access denied");
    }

    /**
     * @dev initializes a new ContractRegistryClient instance
     *
     * @param  _registry   address of a contract-registry contract
     */
    constructor(IGameRegistry _registry) {
        registry = IGameRegistry(_registry);
    }

    function addressOf(
        bytes32 game,
        bytes32 object
    ) external view returns (address) {
        return registry.addressOf(game, object);
    }
}
