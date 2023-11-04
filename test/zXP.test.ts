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
    let stakerRewards: Contract;
    let gameRegistry: Contract;
    let seasonRegistry: Contract;
    let gameVault: Contract;
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

        const stakerRewardsFactory = await hre.ethers.getContractFactory("StakerRewards");
        const stakerRewardsDeploy = await stakerRewardsFactory.deploy(mockErc20.address, "10", gameVault.address, gameVault.address);
        await stakerRewardsDeploy.deployed();
        stakerRewards = stakerRewardsDeploy;

        p1 = player1.address;
        p2 = player2.address;
        p3 = player3.address;
        s1 = staker1.address;
        s2 = staker2.address;
    });

    it("Creates empty game", async () => {
        await gameRegistry.createGame(gameName, deployer.address, "description", [], []);
    });
    it("Creates game", async () => {
        const sr = ethers.utils.formatBytes32String("SeasonRegistry");
        const names = [sr];
        const objects = [seasonRegistry.address];

        const tg = ethers.utils.formatBytes32String("TestGame");
        await gameRegistry.createGame(tg, deployer.address, "description", names, objects);
    });
    it("Registers GameVault", async () => {
        const gameVaultBytes = ethers.utils.formatBytes32String("GameVault");
        await gameRegistry.registerObjects(gameName, [gameVaultBytes], [gameVault.address]);
    });
    it("Registers SeasonRegistry", async () => {
        const sr = ethers.utils.formatBytes32String("SeasonRegistry");
        await gameRegistry.registerObjects(gameName, [sr], [seasonRegistry.address]);
    });
    const numSeasons = 3
    for (let index = 0; index < numSeasons; index++) {
        it("Mints staker 1 NFT", async () => {
            s1nft = s1nft + 3;
            await mockErc721.connect(deployer).mint(s1, s1nft);
        });
        it("Staker 1 stakes NFT", async () => {
            console.log(s1nft);
            await mockErc721.connect(staker1)["safeTransferFrom(address,address,uint256)"](s1, gameVault.address, s1nft);
        });
        it("Mints Staker 2 NFT", async () => {
            //s2nft = ethers.utils.keccak256(ethers.utils.formatBytes32String((index + 1).toString()));
            s2nft = s2nft + 3;
            console.log(s2nft);
            await mockErc721.connect(deployer).mint(s2, s2nft);
        });
        it("Player2 stakes NFT", async () => {
            await mockErc721.connect(staker2)["safeTransferFrom(address,address,uint256)"](s2, gameVault.address, s2nft);
        });
        it("Funds player reward tokens", async () => {
            await mockErc20.connect(deployer)["transfer(address,uint256)"](top3Rewards.address, "1000000000000000000000000");
            await mockErc20.connect(deployer)["transfer(address,uint256)"](stakerRewards.address, "1000000000000000000000000");
        });
        it("Funds staker reward tokens", async () => {
            await mockErc20.connect(deployer)["transfer(address,uint256)"](top3Rewards.address, "1000000000000000000000000");
            await mockErc20.connect(deployer)["transfer(address,uint256)"](stakerRewards.address, "1000000000000000000000000");
        });
        it("Registers StakerReward mechanic", async () => {
            const sr = ethers.utils.formatBytes32String("StakerRewards");
            await seasonRegistry.registerMechanics([sr], [stakerRewards.address]);
        });
        it("Starts the season", async () => {
            await seasonRegistry.startSeason();
        });
        const numRounds = 100;

        for (let i = 0; i < numRounds; i++) {
            const str = "Submits round " + i.toString() + " results";
            it(str, async () => {
                firstReward = "1000000000000000000000";
                secondReward = "100000000000000000000";
                thirdReward = "10000000000000000000";
                await top3Rewards.submitTop3Results(p1, p2, p3, firstReward, secondReward, thirdReward);
            });
        }
        it("Player 1 claims season rewards", async () => {
            await top3Rewards.connect(player1).claim(p1);
            expect(await mockErc20.balanceOf(p1) == firstReward);
        });
        it("Staker 1 unstakes and claims rewards", async () => {
            await gameVault.connect(staker1).withdrawTo(s1, [s1nft]);
        });
        it("Staker 2 claims rewards without unstaking", async () => {
            await stakerRewards.connect(staker2).claim(s2nft);
        });
        it("Ends the season", async () => {
            await seasonRegistry.endSeason();
        });
    }
});