// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGameRegistryClient {
    function only(bytes32 game, bytes32 object) external view;
}
