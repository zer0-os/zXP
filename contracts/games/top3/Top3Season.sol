// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {RewardVault} from "./mechanics/";
import {ITop3Award} from "./interfaces/ITop3Award.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ISeason} from "./interfaces/ISeason.sol";

contract Top3Season is Ownable, ISeason {
    uint public currentSeason;
    bool public offSeason;
    bool public seasonInitialized;
    bool public seasonStarted;
    bool public seasonEnded;

    constructor() {
        offSeason = true;
    }

    startSeason()
}
