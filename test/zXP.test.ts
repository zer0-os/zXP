import * as hre from "hardhat";
import { expect } from "chai";
const { waffle, ethers } = require('hardhat');
const { deployMockContract, provider } = waffle;
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployZNS } from "./helpers/deployZNS";
import { hashDomainLabel, hashSubdomainName } from "./helpers/hashing";
import { ZNSContracts, DeployZNSParams } from "./helpers/types";

// eslint-disable-next-line @typescript-eslint/no-var-requires
require("@nomicfoundation/hardhat-chai-matchers");

describe("ZNSRegistry", () => {
    let deployer: SignerWithAddress;
    let operator: SignerWithAddress;
    let randomUser: SignerWithAddress;

    // An address will be all that's needed to test the Registry
    let mockResolver: SignerWithAddress;
    let mockRegistrar: SignerWithAddress;

    let zns: ZNSContracts;
    let wilderDomainHash: string;

    beforeEach(async () => {
        [deployer, operator, randomUser, mockResolver, mockRegistrar] = await hre.ethers.getSigners();


        const MyERC20 = require('../artifacts/contracts/MyERC20.sol/MyERC20.json');
        const mockedMyERC20 = await deployMockContract(deployer, MyERC20.abi);

        zns = await deployZNS(params);

        wilderDomainHash = hashSubdomainName("wilder");

        await zns.accessController.connect(deployer).grantRole(REGISTRAR_ROLE, mockRegistrar.address);

        await zns.registry.connect(mockRegistrar).createDomainRecord(
            wilderDomainHash,
            deployer.address,
            mockResolver.address
        );
    });

    it("Cannot be initialized twice", async () => {
        await expect(
            zns.registry.initialize(
                zns.accessController.address
            )
        ).to.be.revertedWith(
            INITIALIZED_ERR
        );
    });
});