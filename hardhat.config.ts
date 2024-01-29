/* eslint-disable @typescript-eslint/no-var-requires, @typescript-eslint/no-unused-vars */
require("dotenv").config();

import { HardhatUserConfig } from "hardhat/config";
import * as tenderly from "@tenderly/hardhat-tenderly";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";
import "@openzeppelin/hardhat-upgrades";
import "solidity-coverage";
import "solidity-docgen";

// This call is needed to initialize Tenderly with Hardhat,
// the automatic verifications, though, don't seem to work,
// needing us to verify explicitly in code, however,
// for Tenderly to work properly with Hardhat this method
// needs to be called. The call below is commented out
// because if we leave it here, solidity-coverage
// does not work properly locally or in CI, so we
// keep it commented out and uncomment when using DevNet
// locally.
// !!! Uncomment this when using Tenderly DevNet !!!
//tenderly.setup({ automaticVerifications: false });

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  typechain: {
    outDir: "typechain",
  },
  mocha: {
    timeout: 5000000,
  },
  networks: {
    mainnet: {
      url: process.env.MAINNET_RPC_URL,
      gasPrice: 80000000000,
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      timeout: 10000000,
      accounts: [process.env.PRIVATE_KEY1!, process.env.PRIVATE_KEY2!, process.env.PRIVATE_KEY3!, process.env.PRIVATE_KEY4!, process.env.PRIVATE_KEY5!, process.env.PRIVATE_KEY6!, process.env.PRIVATE_KEY7!, process.env.PRIVATE_KEY8!, process.env.PRIVATE_KEY9!] //pub key 0x6BC8F26172E1bbd3139f951893d6d5d1b669375d
      //chainId: 11155111
    },
    devnet: {
      // Add current URL that you spawned if not using automated spawning
      url: `${process.env.DEVNET_RPC_URL}`,
      chainId: 1,
    },
  },
  etherscan: {
    apiKey: `${process.env.ETHERSCAN_API_KEY}`,
  },
  tenderly: {
    project: `${process.env.TENDERLY_PROJECT_SLUG}`,
    username: `${process.env.TENDERLY_ACCOUNT_ID}`,
  },
  docgen: {
    pages: "files",
    templates: "docs/docgen-templates",
    outputDir: "docs/contracts",
    exclude: [
      "tokens"
    ],
  },
};

export default config;
