// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IRewardVault} from "../interfaces/IRewardVault.sol";
import {ITop3Award} from "../interfaces/ITop3Award.sol";
import {ISeason} from "../interfaces/ISeason.sol";

contract Top3Award is Ownable, ITop3Award {
    IERC20 public awardToken;
    IERC721 public stakedToken;
    ISeason public season;
    address public rewardVault;
    address public official;
    uint public maxRounds;
    uint private roundLength;
    uint private roundFirstAward;
    uint private roundSecondAward;
    uint private roundThirdAward;
    uint public roundStakerAward;
    uint private startTime;
    uint public roundsResolved;
    bool private initialized;
    mapping(address player => uint winnings) public playerWinnings;

    constructor(address _official) {
        Ownable(_official);
    }

    function claimWinnings() external {
        awardToken.transfer(msg.sender, playerWinnings[msg.sender]);
    }

    function initialize(
        IERC20 erc20AwardToken,
        ISeason _season,
        IRewardVault _rewardVault,
        uint _maxRounds,
        uint _roundFirstAward,
        uint _roundSecondAward,
        uint _roundThirdAward,
        uint _roundStakerAward
    ) external override onlyOwner {
        require(!initialized, "Top3 already initialized");
        require(!_season.offSeason(), "Currently off season");
        require(
            awardToken.balanceOf(address(this)) >=
                _rewardVault.numStaked() *
                    _roundStakerAward +
                    _maxRounds *
                    (roundFirstAward + roundSecondAward + roundThirdAward),
            "Insufficient balance"
        );
        awardToken = erc20AwardToken;
        rewardVault = _rewardVault;
        maxRounds = _maxRounds;
        roundFirstAward = _roundFirstAward;
        roundSecondAward = _roundSecondAward;
        roundThirdAward = _roundThirdAward;
        roundStakerAward = _roundStakerAward / _rewardVault.numStaked();
        startTime = block.timestamp;
    }

    function submitTop3Results(
        address first,
        address second,
        address third
    ) external override onlyOwner {
        roundsResolved++;
        playerWinnings[first] += roundFirstAward;
        playerWinnings[second] += roundSecondAward;
        playerWinnings[third] += roundThirdAward;
        awardToken.transfer(rewardVault, roundStakerAward);
    }

    function removeTokens(IERC20 token) external override onlyOwner {
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}
