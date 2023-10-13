// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISeasonRegistry} from "./interfaces/ISeasonRegistry.sol";
import {ISeasonRegistryClient} from "./interfaces/ISeasonRegistryClient.sol";

/**
 * @dev Base contract for Registry clients
 */
contract SeasonRegistryClient is ISeasonRegistryClient {
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
    function _only(bytes32 name, uint season) internal view {
        require(
            msg.sender == registry.addressOf(name, season),
            "ZXP: Access denied"
        );
    }

    /**
     * @dev initializes a new ContractRegistryClient instance
     *
     * @param  _registry   address of a contract-registry contract
     */
    constructor(IGameRegistry _registry) {
        registry = ISeasonRegistry(_registry);
    }
}
