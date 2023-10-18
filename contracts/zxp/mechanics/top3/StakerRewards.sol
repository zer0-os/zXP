// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStakerRewards} from "./interfaces/IStakerRewards.sol";

contract StakerRewards is IStakerRewards {
    IERC20 public rewardToken;

    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;
    }
}
