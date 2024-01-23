// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ISecretRewards} from "./interfaces/ISecretRewards.sol";
import {ObjectRegistryClient} from "../../../ObjectRegistryClient.sol";
import {IObjectRegistry} from "../../../interfaces/IObjectRegistry.sol";
import {ISeasons} from "../../interfaces/ISeasons.sol";

contract SecretRewards is ObjectRegistryClient, Ownable, IPlayerRewards {
    bytes32 internal constant name = "SecretRewards";
    IERC20 public rewardToken;
    uint public xpReward;
    ISeasons private season;
    mapping(address awardee => uint amount) public rewards;

    constructor(
        address owner,
        IERC20 erc20RewardToken,
        ISeasons seasonManager,
        uint xpRewarded
    )
        ObjectRegistryClient(
            IObjectRegistry(
                seasonManager.getRegistryAddress(seasonManager.currentSeason())
            )
        )
    {
        rewardToken = erc20RewardToken;
        xpReward = xpRewarded;
        season = seasonManager;
        Ownable(owner);
    }

    struct Commitment {
        bytes32 guessHash;
        bool isRevealed;
    }

    mapping(address player => Commitment guess) public commitments;
    bytes32 public secretHash; // The hash of the secret
    bool public isGameActive;
    uint256 public revealEndTime;

    // Events
    event Commit(address indexed player);
    event Reveal(address indexed player, string guess);
    event GameResult(string result);

    constructor(bytes32 _secretHash) {
        secretHash = _secretHash;
        isGameActive = true;
    }

    // Players commit their hashed guess
    function commitGuess(bytes32 _guessHash) public override {
        require(isGameActive, "Game is not active");
        require(commitments[msg.sender].guessHash == 0, "Already committed");

        commitments[msg.sender] = Commitment({
            guessHash: _guessHash,
            isRevealed: false
        });

        emit Commit(msg.sender);
    }

    // Starts the reveal phase
    function startRevealPhase(uint256 duration) public override {
        // Add logic for who can start the reveal phase and when
        revealEndTime = block.timestamp + duration;
    }

    // Players reveal their guess
    function revealGuess(
        string memory guess,
        string memory nonce
    ) public override {
        require(block.timestamp < revealEndTime, "Reveal phase over");
        require(
            keccak256(abi.encodePacked(guess, nonce, msg.sender)) ==
                commitments[msg.sender].guessHash,
            "Invalid reveal"
        );

        commitments[msg.sender].isRevealed = true;
        emit Reveal(msg.sender, guess);

        // Add logic for checking the guess against the secret
    }

    // Conclude the game
    function concludeGame() public override {
        require(block.timestamp >= revealEndTime, "Reveal phase not over");
        // Add logic to determine the winner or outcome
        isGameActive = false;
        emit GameResult("Game concluded");
    }

    // Utility function to hash player's guess with nonce and address
    function hashGuess(
        string memory guess,
        string memory nonce
    ) public view override returns (bytes32) {
        return keccak256(abi.encodePacked(guess, nonce, msg.sender));
    }
}
