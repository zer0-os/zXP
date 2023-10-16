// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISeasonRegistry} from "./interfaces/ISeasonRegistry.sol";
import {ISeasonRegistryClient} from "./interfaces/ISeasonRegistryClient.sol";

/**
 * @dev Base contract for Registry clients
 */
contract SeasonRegistryClient is ISeasonRegistryClient {
    ISeasonRegistry public registry; // address of the registry

    /**
     * @dev verifies that the caller is mapped to the given contract name
     *
     * @param name    registrant name
     */
    modifier only(uint season, bytes32 name) {
        _only(season, name);
        _;
    }

    // error message binary size optimization
    function _only(uint season, bytes32 name) internal view {
        require(
            msg.sender == registry.addressOf(season, name),
            "ZXP: Access denied"
        );
    }

    /**
     * @dev initializes a new ContractRegistryClient instance
     *
     * @param  _registry   address of a contract-registry contract
     */
    constructor(ISeasonRegistry _registry) {
        registry = ISeasonRegistry(_registry);
    }
}
