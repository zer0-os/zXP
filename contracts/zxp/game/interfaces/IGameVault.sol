// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IGameRegistry} from "../../interfaces/IGameRegistry.sol";

interface IGameVault {
    function stakedAt(uint id) external view returns (uint);
}
