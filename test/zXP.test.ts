import * as hre from "hardhat";
import { ethers, Contract, BigNumber, providers } from "ethers";
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
        [deployer, official, player1, player2, player3, staker1, staker2] = await hre.ethers.getSigners();

        previousP1XP = BigNumber.from("0");
        previousP2XP = BigNumber.from("0");
        previousP3XP = BigNumber.from("0");
        previousP1Bal = BigNumber.from("0");
        previousP2Bal = BigNumber.from("0");
        previousP3Bal = BigNumber.from("0");

        playerXPReward = 100;

        const erc20Contracts = await hre.ethers.getContractFactory("MockERC20");
        const erc20 = await erc20Contracts.deploy("zToken", "WILD");
        await erc20.deployed();
        mockErc20 = erc20;
        const erc721Contracts = await hre.ethers.getContractFactory("MockERC721");
        const erc721 = await erc721Contracts.deploy("zToken", "WILD", "");
        await erc721.deployed();
        mockErc721 = erc721;

        gameName = ethers.utils.formatBytes32String("game0");
        const gamesFactory = await hre.ethers.getContractFactory("Games");
        const gamesDeploy = await gamesFactory.deploy();
        await gamesDeploy.deployed();
        games = gamesDeploy;

        //create empty game
        await games.createGame(gameName, deployer.address, "description", [], []);
        const storedGame = await games.games(gameName);
        const gameObjects = storedGame.objects;
        const ObjectRegistryFactory = await hre.ethers.getContractFactory("ObjectRegistry");
        gameRegistry = await ObjectRegistryFactory.attach(gameObjects);

        const seasonFactory = await hre.ethers.getContractFactory("Seasons");
        const seasonDeploy = await seasonFactory.deploy(gameRegistry.address);
        await seasonDeploy.deployed();
        seasons = seasonDeploy;

        const gameVaultFactory = await hre.ethers.getContractFactory("GameVault");
        const gameVaultDeploy = await gameVaultFactory.deploy(mockErc721.address, mockErc20.address, "StakedNFT", "SNFT", gameRegistry.address, gameName);
        await gameVaultDeploy.deployed();
        gameVault = gameVaultDeploy;

        const xpFactory = await hre.ethers.getContractFactory("XP");
        const xpDeploy = await xpFactory.deploy("zXP", "XP", gameRegistry.address, gameName);
        await xpDeploy.deployed();
        xp = xpDeploy;

        const levelFactory = await hre.ethers.getContractFactory("LevelCurve");
        const levelDeploy = await levelFactory.deploy([], [], "24", "0");
        await levelDeploy.deployed();
        level = levelDeploy;

        p1 = player1.address;
        p2 = player2.address;
        p3 = player3.address;
        s1 = staker1.address;
        s2 = staker2.address;
    });
    it("Registers GameVault", async () => {
        const gameVaultBytes = ethers.utils.formatBytes32String("GameVault");
        await gameRegistry.registerObjects([gameVaultBytes], [gameVault.address]);
    });
    it("Registers XP", async () => {
        const xpBytes = ethers.utils.formatBytes32String("XP");
        await gameRegistry.registerObjects([xpBytes], [xp.address]);
        expect(await gameRegistry.addressOf(xpBytes)).to.equal(xp.address)
    });
    it("Registers Seasons", async () => {
        const seasonBytes = ethers.utils.formatBytes32String("Seasons");
        await gameRegistry.registerObjects([seasonBytes], [seasons.address]);
    });

    const numSeasons = 1
    for (let i = 0; i < numSeasons; i++) {
        it("Mints staker 1 NFT", async () => {
            s1nft = s1nft + 3;
            await mockErc721.connect(deployer).mint(s1, s1nft);
        });
        it("Staker 1 stakes NFT", async () => {
            await mockErc721.connect(staker1)["safeTransferFrom(address,address,uint256)"](s1, gameVault.address, s1nft);
        });
        it("Mints Staker 2 NFT", async () => {
            s2nft = s2nft + 3;
            await mockErc721.connect(deployer).mint(s2, s2nft);
        });
        it("Player2 stakes NFT", async () => {
            await mockErc721.connect(staker2)["safeTransferFrom(address,address,uint256)"](s2, gameVault.address, s2nft);
        });
        it("Gets season registry", async () => {
            const storedSeason = await seasons.seasons(await seasons.currentSeason());
            const storedRegistry = storedSeason.objects;
            const ObjectRegistryFactory = await hre.ethers.getContractFactory("ObjectRegistry");
            seasonRegistry = await ObjectRegistryFactory.attach(storedRegistry);
        });
        it("Registers StakerRewards", async () => {
            const stakerRewardsFactory = await hre.ethers.getContractFactory("StakerRewards");
            const stakerRewardsDeploy = await stakerRewardsFactory.deploy(mockErc20.address, "10", gameVault.address, gameVault.address, seasons.address);
            await stakerRewardsDeploy.deployed();
            stakerRewards = stakerRewardsDeploy;

            const sr = ethers.utils.formatBytes32String("StakerRewards");
            await gameRegistry.registerObjects([sr], [stakerRewards.address]);
            await seasonRegistry.registerObjects([sr], [stakerRewards.address]);
        });
        it("Registers PlayerRewards", async () => {
            const top3rewardsFactory = await hre.ethers.getContractFactory("PlayerRewards");
            const top3deploy = await top3rewardsFactory.deploy(official.address, mockErc20.address, seasons.address, playerXPReward.toString());
            await top3deploy.deployed();
            top3Rewards = top3deploy;

            const pr = ethers.utils.formatBytes32String("PlayerRewards");
            await seasonRegistry.registerObjects([pr], [top3Rewards.address]);
        });
        it("Registers SecretRewards", async () => {
            const secretsFactory = await hre.ethers.getContractFactory("SecretRewards");
            const secretsDeploy = await secretsFactory.deploy(mockErc20.address, seasons.address, "121");
            await secretsDeploy.deployed();
            secretRewards = secretsDeploy;

            try {
                await hre.run("verify:verify", {
                    address: secretRewards.address,
                    constructorArguments: [
                        mockErc20.address,
                        seasons.address,
                        "121"
                    ],
                })
            } catch (error) { console.log(error) };

            const sr = ethers.utils.formatBytes32String("SecretRewards");
            await seasonRegistry.registerObjects([sr], [secretRewards.address]);
        });

        it("Commits secret", async () => {
            let secret = "verysecretwordshhh";
            let nonce = 123123123;
            let secretHash = secretRewards.hashCommit(deployer.address, nonce, secret)
            await secretRewards.connect(deployer).commitSecret(nonce, secretHash);
        });
        it("Commits correct guess", async () => {
            let guess = "verysecretwordshhh";
            let nonce = 123123123;
            let guessHash = secretRewards.hashCommit(p1, nonce, guess);
            await secretRewards.connect(player1).commitGuess(nonce, guessHash);
        });
        it("Reveals secret", async () => {
            let secret = "verysecretwordshhh";
            let nonce = 123123123;
            await secretRewards.connect(deployer).revealSecret(nonce, secret);
        });
        it("Reveals correct guess, receives XP", async () => {
            let guess = "verysecretwordshhh";
            let nonce = 123123123;
            await secretRewards.connect(player1).revealGuess(nonce, guess);
            expect(await xp.balanceOf(p1)).to.equal(BigNumber.from("121"));
            previousP1XP = BigNumber.from("121");
        });
        it("Funds player reward tokens", async () => {
            await mockErc20.connect(deployer)["transfer(address,uint256)"](top3Rewards.address, "1000000000000000000000000");
            await mockErc20.connect(deployer)["transfer(address,uint256)"](stakerRewards.address, "1000000000000000000000000");
        });
        it("Funds staker reward tokens", async () => {
            await mockErc20.connect(deployer)["transfer(address,uint256)"](top3Rewards.address, "1000000000000000000000000");
            await mockErc20.connect(deployer)["transfer(address,uint256)"](stakerRewards.address, "1000000000000000000000000");
        });

        it("Starts the season", async () => {
            await seasons.startSeason();
        });

        const numRounds = 10;
        for (let i = 0; i < numRounds; i++) {
            const str = "Submits round " + i.toString() + " results";
            it(str, async () => {
                firstReward = "1000000000000000000000";
                secondReward = "100000000000000000000";
                thirdReward = "10000000000000000000";
                await top3Rewards.connect(deployer).submitTop3Results(p1, p2, p3, firstReward, secondReward, thirdReward);
            });

            it("Awarded tokens to winners", async () => {
                let reward1 = BigNumber.from(firstReward);
                let reward2 = BigNumber.from(secondReward);
                let reward3 = BigNumber.from(thirdReward);
                let newP1Bal = previousP1Bal.add(reward1);
                let newP2Bal = previousP2Bal.add(reward2);
                let newP3Bal = previousP3Bal.add(reward3);

                expect(await mockErc20.balanceOf(p1)).to.equal(newP1Bal);
                expect(await mockErc20.balanceOf(p2)).to.equal(newP2Bal);
                expect(await mockErc20.balanceOf(p3)).to.equal(newP3Bal);

                previousP1Bal = newP1Bal;
                previousP2Bal = newP2Bal;
                previousP3Bal = newP3Bal;
            });
            it("Awarded xp to winners", async () => {
                let reward1 = BigNumber.from(playerXPReward * 3);
                let reward2 = BigNumber.from(playerXPReward * 2);
                let reward3 = BigNumber.from(playerXPReward);
                let newP1XP = previousP1XP.add(reward1);
                let newP2XP = previousP2XP.add(reward2);
                let newP3XP = previousP3XP.add(reward3);

                expect(await xp.balanceOf(p1)).to.equal(newP1XP);
                expect(await xp.balanceOf(p2)).to.equal(newP2XP);
                expect(await xp.balanceOf(p3)).to.equal(newP3XP);

                previousP1XP = newP1XP;
                previousP2XP = newP2XP;
                previousP3XP = newP3XP;
            });
            it("Levels up", async () => {
                let p1XP = await xp.balanceOf(p1);
                let playerLevel = await xp.levelAt(p1XP);
                let xpReq = await xp.xpRequired(playerLevel);
                console.log(p1XP.toString());
                console.log(playerLevel.toString());
                console.log(xpReq.toString());
            });
        }
        it("Staker 1 unstakes and claims rewards", async () => {
            await gameVault.connect(staker1).withdrawTo(s1, [s1nft]);
        });
        it("Ends the season", async () => {
            await seasons.endSeason();
        });
    }
});
