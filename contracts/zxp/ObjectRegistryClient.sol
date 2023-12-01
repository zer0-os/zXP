// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IObjectRegistry} from "./interfaces/IGameRegistry.sol";

/**
 * @dev Base contract for Registry clients
 */
contract ObjectRegistryClient is IObjectRegistryClient {
    bytes32 internal constant SEASON_REGISTRY = "SeasonRegistry";
    bytes32 internal constant GAME_VAULT = "GameVault";
    bytes32 internal constant STAKER_REWARDS = "StakerRewards";
    bytes32 internal constant XP = "XP";
    bytes32 internal constant OWNER = "Owner";
    IGameRegistry public registry; // address of the registry
    bytes32 public game; //name of the game

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
        require(
            msg.sender == registry.addressOf(game, object),
            "ZXP: Access denied"
        );
    }

    /**
     * @dev initializes a new ContractRegistryClient instance
     *
     * @param  gameRegistry   address of a contract-registry contract
     */
    constructor(IGameRegistry gameRegistry, bytes32 gameName) {
        registry = gameRegistry;
        game = gameName;
    }
}
