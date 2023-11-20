import * as hre from "hardhat";
import { ethers } from "ethers";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { GameRegistry, GameVault, MockERC20, MockERC721, PlayerRewards, SeasonRegistry, StakerRewards, XP } from "../typechain";

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
    let officialAddress: string;
    let deployerAddress: string;
    let staker1: SignerWithAddress;
    let staker2: SignerWithAddress;
    let mockErc20: MockERC20;
    let mockErc721: MockERC721;
    let top3Rewards: PlayerRewards;
    let stakerRewards: StakerRewards;
    let gameRegistry: GameRegistry;
    let seasonRegistry: SeasonRegistry;
    let gameVault: GameVault;
    let xp: XP;
    let mockErc20Address: string;
    let mockErc721Address: string;
    let top3RewardsAddress: string;
    let stakerRewardsAddress: string;
    let gameRegistryAddress: string;
    let seasonRegistryAddress: string;
    let gameVaultAddress: string;
    let xpAddress: string;
    let firstReward: string;
    let secondReward: string;
    let thirdReward: string;
    let gameName: string;
    let s1nft = 1;
    let s2nft = 2;

    before(async () => {
        [deployer, official, player1, player2, player3, staker1, staker2] = await hre.ethers.getSigners();

        const erc20Contracts = await hre.ethers.getContractFactory("MockERC20");
        const erc20 = await erc20Contracts.deploy("zToken", "WILD");
        await erc20.waitForDeployment();
        mockErc20 = erc20;

        const erc721Contracts = await hre.ethers.getContractFactory("MockERC721");
        const erc721 = await erc721Contracts.deploy("zToken", "WILD", "");
        await erc721.deployed();
        mockErc721 = erc721;

        const gameRegFactory = await hre.ethers.getContractFactory("GameRegistry");
        const gameRegDeploy = await gameRegFactory.deploy();
        await gameRegDeploy.deployed();
        gameRegistry = gameRegDeploy;

        gameName = ethers.encodeBytes32String("game");
        const seasonRegFactory = await hre.ethers.getContractFactory("SeasonRegistry");
        const seasonRegDeploy = await seasonRegFactory.deploy(gameRegistryAddress, gameName);
        await seasonRegDeploy.deployed();
        seasonRegistry = seasonRegDeploy;

        const gameVaultFactory = await hre.ethers.getContractFactory("GameVault");
        const gameVaultDeploy = await gameVaultFactory.deploy(mockErc721Address, mockErc20Address, "StakedNFT", "SNFT", gameRegistryAddress, gameName);
        await gameVaultDeploy.deployed();
        gameVault = gameVaultDeploy;

        const xpFactory = await hre.ethers.getContractFactory("XP");
        const xpDeploy = await xpFactory.deploy("zXP", "XP", gameRegistryAddress, gameName);
        await xpDeploy.deployed();
        xp = xpDeploy;

        const top3rewardsFactory = await hre.ethers.getContractFactory("PlayerRewards");
        const top3deploy = await top3rewardsFactory.deploy(officialAddress, mockErc20Address, seasonRegistryAddress, "0", "100");
        await top3deploy.deployed();
        top3Rewards = top3deploy;

        const stakerRewardsFactory = await hre.ethers.getContractFactory("StakerRewards");
        const stakerRewardsDeploy = await stakerRewardsFactory.deploy(mockErc20Address, "10", gameVaultAddress, gameVaultAddress, seasonRegistryAddress, "0");
        await stakerRewardsDeploy.deployed();
        stakerRewards = stakerRewardsDeploy;

        p1 = await player1.getAddress();
        p2 = await player2.getAddress();
        p3 = await player3.getAddress();
        s1 = await staker1.getAddress();
        s2 = await staker2.getAddress();
        officialAddress = await official.getAddress();
        deployerAddress = await deployer.getAddress();
    });

    it("Creates empty game", async () => {
        await gameRegistry.createGame(gameName, deployerAddress, "description", [], []);
    });
    it("Creates game", async () => {
        const sr = ethers.encodeBytes32String("SeasonRegistry");
        const names = [sr];
        const objects = [seasonRegistryAddress];

        const tg = ethers.encodeBytes32String("TestGame");
        await gameRegistry.createGame(tg, deployerAddress, "description", names, objects);
    });
    it("Registers GameVault", async () => {
        const gameVaultBytes = ethers.encodeBytes32String("GameVault");
        await gameRegistry.registerObjects(gameName, [gameVaultBytes], [gameVaultAddress]);
    });
    it("Registers XP", async () => {
        const xpBytes = ethers.encodeBytes32String("XP");
        await gameRegistry.registerObjects(gameName, [xpBytes], [xpAddress]);
    });
    it("Registers SeasonRegistry", async () => {
        const sr = ethers.encodeBytes32String("SeasonRegistry");
        await gameRegistry.registerObjects(gameName, [sr], [seasonRegistryAddress]);
    });
    it("Registers PlayerRewards", async () => {
        const pr = ethers.encodeBytes32String("PlayerRewards");
        await seasonRegistry.registerMechanics([pr], [top3RewardsAddress]);
    });
    const numSeasons = 3
    for (let index = 0; index < numSeasons; index++) {
        it("Mints staker 1 NFT", async () => {
            s1nft = s1nft + 3;
            await mockErc721.mint(s1, s1nft);
        });
        it("Staker 1 stakes NFT", async () => {
            console.log(s1nft);
            await mockErc721.connect(s1)["safeTransferFrom(address,address,uint256)"](s1, gameVaultAddress, s1nft);
        });
        it("Mints Staker 2 NFT", async () => {
            //s2nft = ethers.keccak256(ethers.encodeBytes32String((index + 1).toString()));
            s2nft = s2nft + 3;
            console.log(s2nft);
            await mockErc721.connect(deployerAddress).mint(s2, s2nft);
        });
        it("Player2 stakes NFT", async () => {
            await mockErc721.connect(s2)["safeTransferFrom(address,address,uint256)"](s2, gameVaultAddress, s2nft);
        });
        it("Funds player reward tokens", async () => {
            //await mockErc20.connect(deployerAddress)["transfer(address,uint256)"](top3RewardsAddress, "1000000000000000000000000");
            //await mockErc20.connect(deployerAddress)["transfer(address,uint256)"](stakerRewardsAddress, "1000000000000000000000000");
        });
        it("Funds staker reward tokens", async () => {
            //await mockErc20.connect(deployerAddress)["transfer(address,uint256)"](top3RewardsAddress, "1000000000000000000000000");
            //await mockErc20.connect(deployerAddress)["transfer(address,uint256)"](stakerRewardsAddress, "1000000000000000000000000");
        });
        it("Registers StakerReward mechanic", async () => {
            const sr = ethers.encodeBytes32String("StakerRewards");
            await seasonRegistry.registerMechanics([sr], [stakerRewardsAddress]);
        });
        it("Starts the season", async () => {
            await seasonRegistry.startSeason();
        });
        const numRounds = 2;

        for (let i = 0; i < numRounds; i++) {
            const str = "Submits round " + i.toString() + " results";
            it(str, async () => {
                firstReward = "1000000000000000000000";
                secondReward = "100000000000000000000";
                thirdReward = "10000000000000000000";
                //await top3Rewards.connect(deployer).submitTop3Results(p1, p2, p3, firstReward, secondReward, thirdReward);
            });
            it("Awards xp to winners", async () => {
                console.log(await xp.balanceOf(p1));
                console.log(await xp.balanceOf(p2));
                console.log(await xp.balanceOf(p3));
            });
            it("Levels up", async () => {
                console.log(await xp.getXPForLevel(i));
            });
        }
        it("Player 1 claims season rewards", async () => {
            //await top3Rewards.connect(player1).claim(p1);
            expect(await mockErc20.balanceOf(p1) == firstReward);
        });
        it("Staker 1 unstakes and claims rewards", async () => {
            //await gameVault.connect(staker1).withdrawTo(s1, [s1nft]);
        });
        it("Staker 2 claims rewards without unstaking", async () => {
            //await stakerRewards.connect(staker2).claim(s2nft);
        });
        it("Awards xp to stakers", async () => {
            //console.log(await xp.balanceOf(staker1Address));
            //console.log(await xp.balanceOf(staker2Address));
        });
        it("Ends the season", async () => {
            await seasonRegistry.endSeason();
        });
    }
});