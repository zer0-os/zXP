// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITop3Rewards {
    function claimWinnings() external;

    function startSeason(
        uint _maxRounds,
        uint _roundFirstReward,
        uint _roundSecondReward,
        uint _roundThirdReward,
        uint _roundStakerReward
    ) external;

    function submitTop3Results(
        address first,
        address second,
        address third
    ) external;

    function finalizeSeason() external;

    function roundsResolved() external view returns (uint);

    function roundStakerAward() external view returns (uint);
}
