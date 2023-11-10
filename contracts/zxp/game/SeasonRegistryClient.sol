// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISeasonRegistry} from "./interfaces/ISeasonRegistry.sol";
import {ISeasonRegistryClient} from "./interfaces/ISeasonRegistryClient.sol";

/**
 * @dev Base contract for Registry clients
 */
contract SeasonRegistryClient is ISeasonRegistryClient {
    bytes32 internal constant STAKER_REWARDS = "StakerRewards";
    bytes32 internal constant PLAYER_REWARDS = "PlayerRewards";
    ISeasonRegistry public registry; // address of the registry
    uint public season;

    /**
     * @dev verifies that the caller is mapped to the given contract name
     *
     * @param name    registrant name
     */
    modifier only(bytes32 name) {
        _only(name);
        _;
    }

    // error message binary size optimization
    function _only(bytes32 name) internal view {
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
    constructor(ISeasonRegistry _registry, uint _season) {
        registry = ISeasonRegistry(_registry);
        season = _season;
    }
}
