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
    let mockErc20: Contract;
    let mockErc721: Contract;
    let top3season: Contract;

    before(async () => {
        [deployer, official, player1, player2] = await hre.ethers.getSigners();

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
    });
    it("Players stake NFTs", async () => {
        const p1 = player1.address;
        const p2 = player2.address;
        const p1nft = 1;
        const p2nft = 2;
        await mockErc721.mint(p1, p1nft);
        await mockErc721.mint(p2, p2nft);
        await mockErc721.connect(player1)["safeTransferFrom(address,address,uint256)"](p1, top3season.address, p1nft);
        await mockErc721.connect(player2)["safeTransferFrom(address,address,uint256)"](p2, top3season.address, p2nft);
    });
    it("Funds reward tokens", async () => {
        mockErc20.connect(deployer)["transfer(address,uint256)"](top3season.address, 10000);
    });
    it("Starts the season", async () => {
        const maxRounds = 10;
        const firstReward = 40;
        const secondReward = 20;
        const thirdReward = 10;
        const stakerReward = 30;
        await top3season.startSeason(maxRounds, firstReward, secondReward, thirdReward, stakerReward);
    });
    it("Submits round 1 results", async () => {

    });

    it("Player 1 claims rewards", async () => {

    });

    it("Submits round 2 results", async () => {

    });

    it("Ends the season", async () => {

    });
    it("Player 2 claims rewards", async () => {

    });
    it("Starts new season", async () => {

    });
});