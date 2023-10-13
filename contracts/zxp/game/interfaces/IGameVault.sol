// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGameVault {
    function claimRewards(address to, uint season) external;
}
