// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISeason {
    function startSeason() external;

    function endSeason() external;

    function currentSeason() external view returns (bool);

    function offSeason() external view returns (bool);
}
