// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ObjectRegistry} from "../../ObjectRegistry.sol";

interface ISeasons {
    function startSeason() external;

    function endSeason() external;

    function onUnstake(uint id, address to, uint blocks) external;

    function awardXP(address to, uint amount) external;

    function getObjectsAddress(uint season) external view returns (address);

    function currentSeason() external view returns (uint);

    function test() external view returns (address);
}
