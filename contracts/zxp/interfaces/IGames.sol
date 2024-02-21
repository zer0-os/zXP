// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGames {
    function createGame(
        bytes32 name,
        address owner,
        string calldata metadata
    ) external;
}
