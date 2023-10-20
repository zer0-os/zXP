// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IStakerRewards {
    function claim(address to) external;

    function onUnstake(uint id, address to, uint blocksStaked) external;
}
