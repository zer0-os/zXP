// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGameRegistry} from "./IGameRegistry.sol";

/**
 * @dev Base contract for Registry clients
 */
interface IGameRegistryClient {
    function only(bytes32 _contractName, uint _season) external view;

    function addressOf(
        bytes32 game,
        bytes32 object
    ) external view returns (address);
}
