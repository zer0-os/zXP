// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRewardVault {
    function finalizeSeason() external;

    function claimRewards(address to, uint season) external;

    function numStaked() external view returns (uint);
}
