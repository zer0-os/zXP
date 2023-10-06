// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITop3Award {
    function claimWinnings() external;

    function initialize(
        IERC20 erc20AwardToken,
        address _awardVault,
        uint _roundLength,
        uint _roundFirstAward,
        uint _roundSecondAward,
        uint _roundThirdAward,
        uint _roundStakerAward
    ) external;

    function submitTop3Results(
        address first,
        address second,
        address third
    ) external;

    function removeTokens(IERC20 token) external;

    function roundsResolved() external view returns (uint);

    function roundStakerAward() external view returns (uint);
}
