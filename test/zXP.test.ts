import * as hre from "hardhat";
import { Contract } from "ethers";
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
    let top3season: Contract;
    const p1nft = 1;
    const p2nft = 2;
    const p3nft = 3;

    before(async () => {
        [deployer, official, player1, player2, player3, staker1, staker2] = await hre.ethers.getSigners();

        const erc20Contracts = await hre.ethers.getContractFactory("MockERC20");
        const _erc20 = await erc20Contracts.deploy("zToken", "WILD");
        await _erc20.deployed();
        mockErc20 = _erc20;

        const erc721Contracts = await hre.ethers.getContractFactory("MockERC721");
        const _erc721 = await erc721Contracts.deploy("zToken", "WILD", "");
        await _erc721.deployed();
        mockErc721 = _erc721;

        const top3seasonContracts = await hre.ethers.getContractFactory("Top3Seasons");
        const _top3season = await top3seasonContracts.deploy(official.address, mockErc721.address, mockErc20.address, "StakedNFT", "SNFT");
        await _top3season.deployed();
        top3season = _top3season;

        p1 = player1.address;
        p2 = player2.address;
        p3 = player3.address;
        s1 = staker1.address;
        s2 = staker2.address;
    });
    it("Players stake NFTs", async () => {
        await mockErc721.mint(s1, p1nft);
        await mockErc721.mint(s2, p2nft);
        await mockErc721.connect(staker1)["safeTransferFrom(address,address,uint256)"](s1, top3season.vaultAddress(), p1nft);
        await mockErc721.connect(staker2)["safeTransferFrom(address,address,uint256)"](s2, top3season.vaultAddress(), p2nft);
    });
    it("Funds reward tokens", async () => {
        await mockErc20.connect(deployer)["transfer(address,uint256)"](top3season.address, "1000000000000000000000000");
    });
    it("Starts the season", async () => {
        const maxRounds = 10;
        const firstReward = 4;
        const secondReward = 2;
        const thirdReward = 1;
        const stakerReward = 3;
        await top3season.startSeason(maxRounds, firstReward, secondReward, thirdReward, stakerReward);
    });
    it("Submits round 1 results", async () => {
        await top3season.resolveRound(p1, p2, p3);
    });
    it("Submits round 2 results", async () => {
        await top3season.resolveRound(p3, p2, p1);
    });
    it("Ends the season", async () => {
        await top3season.endSeason();
    });
    it("Player 1 claims season rewards", async () => {
        await top3season.connect(player1).claimRewards(0);
    });
    it("Player 2 claims season rewards", async () => {
        await top3season.connect(player2).claimRewards(0);
    });
    it("Player 2 claims season rewards", async () => {
        await top3season.connect(player3).claimRewards(0);
    });
    it("Staker1 claims rewards", async () => {
        await top3season.connect(staker1).claimRewards(0);
    });
    it("Staker2 claims rewards", async () => {
        await top3season.connect(staker2).claimRewards(0);
    });
    it("Funds reward tokens", async () => {
        await mockErc20.connect(deployer)["transfer(address,uint256)"](top3season.address, "1000000000000000000000000");
    });
    it("Starts new season", async () => {
        const maxRounds = 10;
        const firstReward = 4;
        const secondReward = 2;
        const thirdReward = 1;
        const stakerReward = 3;
        await top3season.startSeason(maxRounds, firstReward, secondReward, thirdReward, stakerReward);
    });
    it("Submits round 1 results", async () => {
        await top3season.resolveRound(p1, p2, p3);
    });
    it("Submits round 2 results", async () => {
        await top3season.resolveRound(p3, p2, p1);
    });
    it("Ends the season", async () => {
        await top3season.endSeason();
    });
    it("Player 1 claims season rewards", async () => {
        await top3season.connect(player1).claimRewards(0);
    });
    it("Player 2 claims season rewards", async () => {
        await top3season.connect(player2).claimRewards(0);
    });
    it("Staker1 claims rewards", async () => {
        await top3season.connect(staker1).claimRewards(0);
    });
    it("Staker2 claims rewards", async () => {
        await top3season.connect(staker2).claimRewards(0);
    });
});