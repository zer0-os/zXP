// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISecretRewards {
    function commitGuess(bytes32 _guessHash) external;

    function startRevealPhase(uint256 duration) external;

    function revealGuess(string memory guess, string memory nonce) external;

    function concludeGame() external;

    function hashGuess(
        string memory guess,
        string memory nonce
    ) external view returns (bytes32);
}
