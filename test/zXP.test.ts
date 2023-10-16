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
    let top3rounds: Contract;
    let maxRounds: string;
    let firstReward: string;
    let secondReward: string;
    let thirdReward: string;
    let stakerReward: string;
    const s1nft = 1;
    const s2nft = 2;

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

        const top3RoundsContracts = await hre.ethers.getContractFactory("Top3Rounds");
        const _top3Rounds = await top3RoundsContracts.deploy(official.address, mockErc721.address, mockErc20.address, "StakedNFT", "SNFT");
        await _top3Rounds.deployed();
        top3rounds = _top3Rounds;

        p1 = player1.address;
        p2 = player2.address;
        p3 = player3.address;
        s1 = staker1.address;
        s2 = staker2.address;
    });
    it("Players stake NFTs", async () => {
        await mockErc721.mint(s1, s1nft
        );
        await mockErc721.mint(s2, s2nft);
        await mockErc721.connect(staker1)["safeTransferFrom(address,address,uint256)"](s1, top3rounds.vaultAddress(), s1nft
        );
        await mockErc721.connect(staker2)["safeTransferFrom(address,address,uint256)"](s2, top3rounds.vaultAddress(), s2nft);
    });
    it("Funds reward tokens", async () => {
        await mockErc20.connect(deployer)["transfer(address,uint256)"](top3rounds.address, "1000000000000000000000000");
    });
    it("Starts the season", async () => {
        maxRounds = "10";
        firstReward = "4000000000000000000";
        secondReward = "2000000000000000000";
        thirdReward = "1000000000000000000";
        stakerReward = "3000000000000000000";
        let collateralRequired = "100000000000000000000"
        await mockErc20.connect(deployer)["transfer(address,uint256)"](top3rounds.address, collateralRequired.toString());
        await top3rounds.startSeason(maxRounds, firstReward, secondReward, thirdReward, stakerReward);
    });
    it("Submits round 1 results", async () => {
        await top3rounds.resolveRound(p1, p2, p3);
    });
    it("Ends the season", async () => {
        await top3rounds.endSeason();
    });
    it("Player 1 claims season rewards", async () => {
        await top3rounds.connect(player1).claimRewards(0);
        expect(await mockErc20.balanceOf(p1) == firstReward);
        expect(await mockErc20.balanceOf(p2) == secondReward);
        expect(await mockErc20.balanceOf(p3) == thirdReward);
    });
    it("Player 2 claims season rewards", async () => {
        await top3rounds.connect(player2).claimRewards(0);
    });
    it("Player 2 claims season rewards", async () => {
        await top3rounds.connect(player3).claimRewards(0);
    });
    it("Staker1 claims rewards", async () => {
        await top3rounds.connect(staker1).claimRewards(0);
    });
    it("Staker2 claims rewards", async () => {
        await top3rounds.connect(staker2).claimRewards(0);
    });
    it("Funds reward tokens", async () => {
        await mockErc20.connect(deployer)["transfer(address,uint256)"](top3rounds.address, "1");
    });
    it("Starts new season", async () => {
        maxRounds = "10";
        firstReward = "4000000000000000000";
        secondReward = "2000000000000000000";
        thirdReward = "1000000000000000000";
        stakerReward = "3000000000000000000";
        let collateralRequired = "100000000000000000000"
        await mockErc20.connect(deployer)["transfer(address,uint256)"](top3rounds.address, collateralRequired.toString());
        await top3rounds.startSeason(maxRounds, firstReward, secondReward, thirdReward, stakerReward);
    });
    it("Submits round 1 results", async () => {
        await top3rounds.resolveRound(p1, p2, p3);
        expect(await mockErc20.balanceOf(p1) == firstReward);
        expect(await mockErc20.balanceOf(p2) == secondReward);
        expect(await mockErc20.balanceOf(p3) == thirdReward);
    });
    it("Submits round 2 results", async () => {
        await top3rounds.resolveRound(p3, p2, p1);
    });
    it("Ends the season", async () => {
        await top3rounds.endSeason();
    });
    it("Player 1 claims season rewards", async () => {
        await top3rounds.connect(player1).claimRewards(0);
    });
    it("Player 2 claims season rewards", async () => {
        await top3rounds.connect(player2).claimRewards(0);
    });
    it("Staker1 claims rewards", async () => {
        await top3rounds.connect(staker1).claimRewards(0);
    });
    it("Staker2 claims rewards", async () => {
        await top3rounds.connect(staker2).claimRewards(0);
    });
});