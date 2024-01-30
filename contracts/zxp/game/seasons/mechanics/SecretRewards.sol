// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ISecretRewards {
    function commitGuess(uint nonce, bytes32 _guessHash) external;

    function revealGuess(uint nonce, string memory guess) external;

    function commitSecret(uint nonce, bytes32 _secretHash) external;

    function revealSecret(uint nonce, string memory secret) external;

    function hashCommit(
        address player,
        uint nonce,
        string memory secret
    ) external view returns (bytes32);
}

contract SecretRewards is ISecretRewards {
    bytes32 internal constant OWNER = "Owner";
    bytes32 internal constant OBJECT = "SecretRewards";

    struct Commitment {
        bytes32 secretHash;
        string reveal;
    }

    mapping(uint nonce => Commitment commit) public secrets;
    mapping(address player => mapping(uint nonce => Commitment commit))
        public guesses;

    event SecretCommitted(uint nonce, bytes32 secret);
    event SecretRevealed(uint nonce, string reveal);
    event GuessCommitted(address indexed player, uint nonce, bytes32 secret);
    event GuessRevealed(address indexed player, uint nonce, string reveal);

    function commitGuess(uint nonce, bytes32 guessHash) public override {
        require(
            bytes(secrets[nonce].reveal).length == 0,
            "No overwrite after reveal"
        );
        guesses[msg.sender][nonce] = Commitment({
            secretHash: guessHash,
            reveal: ""
        });
        emit GuessCommitted(msg.sender, nonce, guessHash);
    }

    function revealGuess(uint nonce, string memory guess) public override {
        require(
            hashCommit(msg.sender, nonce, guess) ==
                guesses[msg.sender][nonce].secretHash,
            "Invalid reveal"
        );
        require(
            bytes(secrets[nonce].reveal).length != 0,
            "Answer not revealed"
        );

        emit GuessRevealed(msg.sender, nonce, guess);
    }

    function commitSecret(uint nonce, bytes32 secretHash) public override {
        require(secrets[nonce].secretHash == bytes32(0), "No overwriting");
        secrets[nonce] = Commitment({secretHash: secretHash, reveal: ""});
        emit SecretCommitted(nonce, secretHash);
    }

    function revealSecret(uint nonce, string memory secret) public override {
        require(
            hashCommit(msg.sender, nonce, secret) == secrets[nonce].secretHash,
            "Incorrect secret"
        );
        require(bytes(secrets[nonce].reveal).length == 0, "No overwriting");
        secrets[nonce].reveal = secret;
        emit SecretRevealed(nonce, secret);
    }

    function hashCommit(
        address player,
        uint nonce,
        string memory secret
    ) public pure override returns (bytes32) {
        return keccak256(abi.encode(player, nonce, secret));
    }
}
