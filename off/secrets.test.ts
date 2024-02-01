import * as hre from "hardhat";
import { ethers, Contract, BigNumber } from "ethers";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
// eslint-disable-next-line @typescript-eslint/no-var-requires
require("@nomicfoundation/hardhat-chai-matchers");

describe("ZXP", () => {
    let deployer: SignerWithAddress;
    let official: SignerWithAddress;
    let player1: SignerWithAddress;
    let player2: SignerWithAddress;
    let player3: SignerWithAddress;
    let p1: string;
    let p2: string;
    let p3: string;
    let s1: string;
    let s2: string;
    let staker1: SignerWithAddress;
    let staker2: SignerWithAddress;
    let mockErc20: Contract;
    let mockErc721: Contract;
    let top3Rewards: Contract;
    let stakerRewards: Contract;
    let secretRewards: Contract;
    let games: Contract;
    let seasons: Contract;
    let gameRegistry: Contract;
    let seasonRegistry: Contract;
    let gameVault: Contract;
    let xp: Contract;
    let level: Contract;
    let firstReward: string;
    let secondReward: string;
    let thirdReward: string;
    let playerXPReward: number;
    let previousP1XP: BigNumber;
    let previousP2XP: BigNumber;
    let previousP3XP: BigNumber;
    let previousP1Bal: BigNumber;
    let previousP2Bal: BigNumber;
    let previousP3Bal: BigNumber;
    let gameName: string;
    let s1nft = 1;
    let s2nft = 2;
    let storedSeasonObjects: Contract;

    before(async () => {
        [deployer] = await hre.ethers.getSigners();

        previousP1XP = BigNumber.from("0");
        previousP2XP = BigNumber.from("0");
        previousP3XP = BigNumber.from("0");
        previousP1Bal = BigNumber.from("0");
        previousP2Bal = BigNumber.from("0");
        previousP3Bal = BigNumber.from("0");

        const secretsFactory = await hre.ethers.getContractFactory("SecretRewards");
        const secretsDeploy = await secretsFactory.deploy();
        await secretsDeploy.deployed();
        secretRewards = secretsDeploy;


        let secret = "verysecretwordshhh";
        let guess = "secret";
        let nonce = 123123123;
        let secretHash = await secretRewards.hashCommit(deployer.address, nonce, secret)

        let tx = await secretRewards.commitSecret(nonce, secretHash);
        await tx.wait();
        let guessHash = await secretRewards.hashCommit(deployer.address, nonce, guess);
        let tx1 = await secretRewards.commitGuess(nonce, guessHash);
        await tx1.wait();
        console.log(await secretRewards.secrets(nonce));


        let tx2 = await secretRewards.revealSecret(nonce, secret);
        await tx2.wait();

        let tx3 = await secretRewards.revealGuess(nonce, guess);
        await tx3.wait();

    });
    it("Commits secret", async () => {
        console.log("?");

        let secret = "snow";
        let nonce = 369;
        let secretHash = await secretRewards.hashCommit(deployer.address, nonce, secret)
        await secretRewards.commitSecret(nonce, secretHash);
    });/*
    it("Commits correct guess", async () => {
        let guess = "verysecretwordshhh";
        let nonce = 123123123;
        let guessHash = await secretRewards.hashCommit(deployer.address, nonce, guess);
        await secretRewards.commitGuess(nonce, guessHash);
        console.log(await secretRewards.secrets(nonce));
    });
    it("Reveals secret", async () => {
        let secret = "verysecretwordshhh";
        let nonce = 123123123;
        await secretRewards.revealSecret(nonce, secret);
    });
    it("Reveals correct guess, receives XP", async () => {

    });*/
});
