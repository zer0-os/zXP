// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IObjectRegistry {
    function registerObjects(
        bytes32[] calldata objectNames,
        address[] calldata objectAddresses
    ) external;

    function addressOf(bytes32 objectName) external view returns (address);
}
