// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRewardVault {
    function finalizeSeason(uint season) external;

    function claimRewards(address to) external;

    function numStaked() external view returns (uint);
}
