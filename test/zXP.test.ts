import * as hre from "hardhat";
import { ethers, Contract } from "ethers";
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
    let gameRegistry: Contract;
    let seasonRegistry: Contract;
    let gameVault: Contract;
    let firstReward: string;
    let secondReward: string;
    let thirdReward: string;
    let gameName: string;
    const s1nft = 1;
    const s2nft = 2;

    before(async () => {
        [deployer, official, player1, player2, player3, staker1, staker2] = await hre.ethers.getSigners();

        const erc20Contracts = await hre.ethers.getContractFactory("MockERC20");
        const erc20 = await erc20Contracts.deploy("zToken", "WILD");
        await erc20.deployed();
        mockErc20 = erc20;

        const erc721Contracts = await hre.ethers.getContractFactory("MockERC721");
        const erc721 = await erc721Contracts.deploy("zToken", "WILD", "");
        await erc721.deployed();
        mockErc721 = erc721;

        const gameRegFactory = await hre.ethers.getContractFactory("GameRegistry");
        const gameRegDeploy = await gameRegFactory.deploy();
        await gameRegDeploy.deployed();
        gameRegistry = gameRegDeploy;

        gameName = ethers.utils.formatBytes32String("game0");
        const seasonRegFactory = await hre.ethers.getContractFactory("SeasonRegistry");
        const seasonRegDeploy = await seasonRegFactory.deploy(gameRegistry.address, gameName);
        await seasonRegDeploy.deployed();
        seasonRegistry = seasonRegDeploy;

        const gameVaultFactory = await hre.ethers.getContractFactory("GameVault");
        const gameVaultDeploy = await gameVaultFactory.deploy(mockErc721.address, mockErc20.address, "StakedNFT", "SNFT", gameRegistry.address, gameName);
        await gameVaultDeploy.deployed();
        gameVault = gameVaultDeploy;

        const top3rewardsFactory = await hre.ethers.getContractFactory("Top3Rewards");
        const top3deploy = await top3rewardsFactory.deploy(official.address, mockErc20.address);
        await top3deploy.deployed();
        top3Rewards = top3deploy;

        p1 = player1.address;
        p2 = player2.address;
        p3 = player3.address;
        s1 = staker1.address;
        s2 = staker2.address;
    });

    it("Creates game", async () => {
        await gameRegistry.createGame(gameName, deployer.address, "description", [], []);
    });
    it("Players stake NFTs", async () => {
        await mockErc721.mint(s1, s1nft);
        await mockErc721.mint(s2, s2nft);
        await mockErc721.connect(staker1)["safeTransferFrom(address,address,uint256)"](s1, gameVault.address, s1nft);
        await mockErc721.connect(staker2)["safeTransferFrom(address,address,uint256)"](s2, gameVault.address, s2nft);
    });
    it("Funds reward tokens", async () => {
        await mockErc20.connect(deployer)["transfer(address,uint256)"](top3Rewards.address, "1000000000000000000000000");
    });
    it("Initializes the season", async () => {
        seasonRegistry.startSeason();
    });
    it("Starts the season", async () => {
        seasonRegistry.startSeason();
    });
    it("Submits round 1 results", async () => {
        firstReward = "100";
        secondReward = "10";
        thirdReward = "1";
        await top3Rewards.submitTop3Results(p1, p2, p3, firstReward, secondReward, thirdReward);
    });
    it("Ends the season", async () => {
        await seasonRegistry.endSeason();
    });
    it("Player 1 claims season rewards", async () => {
        await top3Rewards.connect(player1).claim(p1);
        expect(await mockErc20.balanceOf(p1) == firstReward);
    });
});