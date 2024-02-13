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
    // here another double-external call to set the variable that's already available
        ObjectRegistryClient(
            IObjectRegistry(
            // is there a different registry contract for every season?
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

    // what is the reason there's no nonce counter on the contract?
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
            "No overwrite after reveal" // seems like a wrong message
        );
        guesses[msg.sender][nonce] = Commitment({
            secretHash: guessHash,
            reveal: ""
        });
        emit GuessCommitted(msg.sender, nonce, guessHash);
    }

    // Players reveal their guess
    function revealGuess(uint nonce, string memory guess) public override {
        bytes32 guessHash = hashCommit(msg.sender, nonce, guess);

        require(
            guessHash == guesses[msg.sender][nonce].secretHash,
            "Invalid reveal" // unclear message
        );
        require(
            bytes(secrets[nonce].reveal).length != 0,
            "Answer not revealed"
        );
        require(
            // why is this necessary to hash these here and not just compare string directly?
            // what do we miss when just comparing strings?
            keccak256(abi.encode(guess)) ==
                keccak256(abi.encode(secrets[nonce].reveal)),
            "Wrong answer"
        );

        season.awardXP(msg.sender, xpReward, OBJECT);

        emit GuessRevealed(msg.sender, nonce, guess);
    }

    function commitSecret(
        uint nonce,
        bytes32 secretHash
    ) public override only(OWNER) {
        require(secrets[nonce].secretHash == bytes32(0), "No overwriting");
        secrets[nonce] = Commitment({secretHash: secretHash, reveal: ""});
        emit SecretCommitted(nonce, secretHash);
    }

    // this whole flow seems redundant. an user that has the hash
    // (that is available on the contract by the time a user commits a guess,
    // he can locally keep hashing his guesses to get the same hash,
    // once he gets the same hash he (and we) already know that his guess is correct,
    // so we should be able to reward him at guess commit time and this whole reveal secret flow
    // seems redundant
    function revealSecret(
        uint nonce,
        string memory secret
    ) public override only(OWNER) {
        //bytes memory reveal = bytes()
        require(
            hashCommit(msg.sender, nonce, secret) == secrets[nonce].secretHash,
            "Incorrect secret"
        );
        require(bytes(secrets[nonce].reveal).length == 0, "No overwriting");
        secrets[nonce].reveal = secret;
        emit SecretRevealed(nonce, secret);
    }

    // Helper function for hashing secret words
    function hashCommit(
        address player,
        uint nonce,
        string memory secret
    ) public pure override returns (bytes32) {
        return keccak256(abi.encode(player, nonce, secret));
    }
}
