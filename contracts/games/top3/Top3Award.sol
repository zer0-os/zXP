// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ITop3Award} from "./interfaces/ITop3Award.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Top3Award is Ownable, ITop3Award {
    IERC20 public awardToken;
    IERC721 public stakedToken;
    address public awardVault;
    address public official;
    uint public round;
    uint private roundLength;
    uint private roundFirstAward;
    uint private roundSecondAward;
    uint private roundThirdAward;
    uint public roundStakerAward;
    uint private startTime;
    uint public roundsResolved;
    bool private initialized;
    mapping(uint round => bool isResolved) public roundResolved;

    constructor(address _official) {
        Ownable(_official);
    }

    function initialize(
        IERC20 erc20AwardToken,
        address _awardVault,
        uint _roundLength,
        uint _roundFirstAward,
        uint _roundSecondAward,
        uint _roundThirdAward,
        uint _roundStakerAward
    ) external override {
        require(!initialized, "Top3 already initialized");
        awardToken = erc20AwardToken;
        awardVault = _awardVault;
        roundLength = _roundLength;
        roundFirstAward = _roundFirstAward;
        roundSecondAward = _roundSecondAward;
        roundThirdAward = _roundThirdAward;
        roundStakerAward = _roundStakerAward;
        startTime = block.timestamp;
    }

    function submitTop3Results(
        address first,
        address second,
        address third
    ) external override onlyOwner {
        require(
            !roundResolved[(block.timestamp - startTime) / roundLength],
            "ZXP round already resolved"
        );

        roundResolved[(block.timestamp - startTime) / roundLength] = true;
        roundsResolved++;
        awardToken.transfer(first, roundFirstAward);
        awardToken.transfer(second, roundSecondAward);
        awardToken.transfer(third, roundThirdAward);
        awardToken.transfer(awardVault, roundStakerAward);
    }

    function removeTokens(IERC20 token) external override onlyOwner {
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}
