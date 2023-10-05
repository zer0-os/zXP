import * as hre from "hardhat";
import { Signer, Contract } from "ethers";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

// eslint-disable-next-line @typescript-eslint/no-var-requires
require("@nomicfoundation/hardhat-chai-matchers");

describe("ZXP", () => {
    let deployer: SignerWithAddress;
    let operator: SignerWithAddress;
    let randomUser: SignerWithAddress;
    let mockErc20: Contract;

    beforeEach(async () => {
        [deployer, operator, randomUser] = await hre.ethers.getSigners();


        const erc20Contract = await hre.ethers.getContractFactory("MockERC20");
        const _erc20 = await erc20Contract.deploy('Wilder World', 'WILD');
        await _erc20.deployed();
        mockErc20 = _erc20;

    });

    it("", async () => {
        //await expect();
    });
});