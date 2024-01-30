// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISecretRewards00 {
    function commitGuess(uint nonce, bytes32 _guessHash) external;

    function revealGuess(uint nonce, string memory guess) external;

    function commitSecret(uint nonce, bytes32 _secretHash) external;

    function revealSecret(uint nonce, string memory secret) external;

    function hashCommit(
        address player,
        uint nonce,
        string memory secret
    ) external view returns (bytes32);
}
