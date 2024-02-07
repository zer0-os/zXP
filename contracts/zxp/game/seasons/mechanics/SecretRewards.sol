// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISecretRewards} from "./interfaces/ISecretRewards.sol";
import {ObjectRegistryClient} from "../../../ObjectRegistryClient.sol";
import {IObjectRegistry} from "../../../interfaces/IObjectRegistry.sol";
import {ISeasons} from "../../interfaces/ISeasons.sol";

contract SecretRewards is ObjectRegistryClient, ISecretRewards {
    bytes32 internal constant OWNER = "Owner";
    bytes32 internal constant OBJECT = "SecretRewards";
    uint public xpReward;
    ISeasons private season;
    mapping(address player => uint amount) public rewards;

    constructor(
        ISeasons seasonManager,
        uint xpRewarded
    )
        ObjectRegistryClient(
            IObjectRegistry(
                seasonManager.getRegistryAddress(seasonManager.currentSeason())
            )
        )
    {
        xpReward = xpRewarded;
        season = seasonManager;
    }

    struct Commitment {
        bytes32 secretHash;
        string reveal;
    }

    mapping(uint nonce => Commitment commit) public secrets;
    mapping(address player => mapping(uint nonce => Commitment commit))
        public guesses;

    // Events
    event SecretCommitted(uint nonce, bytes32 secret);
    event SecretRevealed(uint nonce, string reveal);
    event GuessCommitted(address indexed player, uint nonce, bytes32 secret);
    event GuessRevealed(address indexed player, uint nonce, string reveal);

    // Players commit their hashed guess
    function commitGuess(uint nonce, bytes32 guessHash) public override {
        require(
            bytes(secrets[nonce].reveal).length == 0,
            "No overwrite after reveal"
        );
        guesses[msg.sender][nonce] = Commitment({
            secretHash: guessHash,
            reveal: "",
            revealed: false
        });
        emit GuessCommitted(msg.sender, nonce, guessHash);
    }

    /** 
        Players reveal their guess
        @dev this function does not check if the guess is empty ""
             and expects this check is done by the secret committer
        @dev does not store the guess, emits in event
    */

    function revealGuess(uint nonce, string memory guess) public override {
        bytes32 guessHash = hashCommit(msg.sender, nonce, guess);

        require(
            guessHash == guesses[msg.sender][nonce].secretHash,
            "Invalid reveal"
        );
        require(
            bytes(secrets[nonce].reveal).length != 0,
            "Answer not revealed"
        );
        require(
            keccak256(abi.encode(guess)) ==
                keccak256(abi.encode(secrets[nonce].reveal)),
            "Wrong answer"
        );
        require(
            guesses[msg.sender][nonce].revealed == false,
            "ZXP: Guess already revealed"
        );
        guesses[msg.sender][nonce].reveal = guess;
        guesses[msg.sender][nonce].revealed = true;
        season.awardXP(msg.sender, xpReward, OBJECT);
        emit GuessRevealed(msg.sender, nonce, guess);
    }

    /**
        Contract owner commits secret
     */
    function commitSecret(
        uint nonce,
        bytes32 secretHash
    ) public override only(OWNER) {
        require(secrets[nonce].secretHash == bytes32(0), "No overwriting");
        secrets[nonce] = Commitment({
            secretHash: secretHash,
            reveal: "",
            revealed: false
        });
        emit SecretCommitted(nonce, secretHash);
    }

    /**
        Contract owner reveals secret
     */
    function revealSecret(
        uint nonce,
        string memory secret,
        uint salt
    ) public override only(OWNER) {
        //bytes memory reveal = bytes()
        require(
            hashCommit(msg.sender, nonce, secret) == secrets[nonce].secretHash,
            "Incorrect secret"
        );
        require(bytes(secrets[nonce].reveal).length == 0, "No overwriting");
        secrets[nonce].reveal = secret;
        emit SecretRevealed(nonce, secret, salt);
    }

    // Helper function for hashing secret words
    function hashCommit(
        address committer,
        uint nonce,
        string memory secret
    ) public pure override returns (bytes32) {
        return keccak256(abi.encode(committer, nonce, secret));
    }
}
