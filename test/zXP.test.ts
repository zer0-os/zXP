import * as hre from "hardhat";
import { Signer, Contract } from "ethers";
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

    beforeEach(async () => {
        [deployer, official, player1, player2] = await hre.ethers.getSigners();

        const erc20Contracts = await hre.ethers.getContractFactory("MockERC20");
        const _erc20 = await erc20Contracts.deploy('zToken', 'WILD');
        await _erc20.deployed();
        mockErc20 = _erc20;

        const erc721Contracts = await hre.ethers.getContractFactory("MockERC721");
        const _erc721 = await erc721Contracts.deploy('zToken', 'WILD');
        await _erc721.deployed();
        mockErc721 = _erc721;

        const top3seasonContracts = await hre.ethers.getContractFactory("Top3Season");
        const _top3season = await top3seasonContracts.deploy(official, mockErc721, mockErc20, "StakedNFT", "SNFT");
        await _top3season.deployed();
        top3season = _top3season
    });
    it("Players stake NFTs", async () => {
        await _beastToken.connect(p2signer)["safeTransferFrom(address,address,uint256)"](player1.address, top3season, 1);
    });
    it("Starts the season", async () => {
        let maxRounds = 10;
        let firstReward = 40;
        let secondReward = 20;
        let thirdReward = 10;
        let stakerReward = 30;
        await top3season.startSeason(maxRounds, firstReward, secondReward, thirdReward, stakerReward);
    });
    it("Submits round results", async () => {

    });
    it("Ends the season", async () => {

    });
});