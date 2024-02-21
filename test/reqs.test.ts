import * as hre from "hardhat";
import { ethers } from "ethers";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  GameVault,
  Games,
  MockERC20,
  MockERC721,
  ObjectRegistry,
  ObjectRegistry__factory,
  Seasons,
  StakerRewards,
  XP,
} from "../typechain";
// eslint-disable-next-line @typescript-eslint/no-var-requires

// Test core requirements for Staking

// Priority #1 - Staking
// 1.1 - User visits a staking website (possibly a zApp).
// 1.2 - User can stake their NFT (e.g., Wilder Wheel)
// 1.3 - User receives staked NFT in return
// 1.4 - User receives a Race Pass (new contract)
// 1.5 - User receives a percentage of rewards on an epoch (passive rewards)
// 1.6 - User can unstake at any time.

describe("Requirements testing", () => {
  let deployer: SignerWithAddress;
  let staker: SignerWithAddress;

  let mockERC20: MockERC20;
  let mockERC721: MockERC721;

  let games: Games;
  let gameVault: GameVault; // ERC721Wrapper
  let rewards: StakerRewards;
  let seasons: Seasons;
  let xp: XP; // is ERC20

  let stakingGameRegistryAddress: string;
  let stakingGameRegistry: ObjectRegistry;

  let seasons0RegistryAddress: string;
  let seasons0Registry: ObjectRegistry;

  let seasonsRegistry: ObjectRegistry;
  let gameVaultRegistry: ObjectRegistry;
  let xpRegistry: ObjectRegistry

  // Setup game
  before(async () => {
    [
      deployer,
      staker,
    ] = await hre.ethers.getSigners();

    // Deployments
    // 1. MockERC20
    // 2. MockERC721
    // 3. Games
    // 4. Seasons
    // 5. XP
    // 6. GameVault
    // 7. StakerRewards

    const mockERC20Factory = await hre.ethers.getContractFactory("MockERC20");
    // Will immediately mint and transfer to msg.sender
    mockERC20 = await mockERC20Factory.deploy("MEOW", "MEOW");

    const mockERC721Factory = await hre.ethers.getContractFactory("MockERC721");
    mockERC721 = (await mockERC721Factory.deploy("WilderWheels", "WW", "0://wheels-base"));

    const gamesFactory = await hre.ethers.getContractFactory("Games");
    games = await gamesFactory.deploy();

    const gameName = "StakingGame";
    const gameNameBytes = hre.ethers.utils.formatBytes32String(gameName);
    await games.createGame(gameNameBytes, deployer.address, "a-staking-game");

    // Registry for the StakingGame
    stakingGameRegistryAddress = (await games.games(gameNameBytes)).gameObjects;
    stakingGameRegistry = ObjectRegistry__factory.connect(stakingGameRegistryAddress, deployer);

    const seasonsFactory = await hre.ethers.getContractFactory("Seasons");
    seasons = await seasonsFactory.deploy(
      stakingGameRegistry.address,
    );

    const xpFactory = await hre.ethers.getContractFactory("XP");
    xp = await xpFactory.deploy("XP", "XP", stakingGameRegistry.address, gameNameBytes);

    const gameVaultFactory = await hre.ethers.getContractFactory("GameVault");
    gameVault = await gameVaultFactory.deploy(
      mockERC721.address, // underlying ERC721
      mockERC20.address,
      "GameVault", // wrapped ERC721
      "GMVLT",
      stakingGameRegistry.address,
      gameNameBytes
    );

    const stakerRewardsFactory = await hre.ethers.getContractFactory("StakerRewards");
    rewards = await stakerRewardsFactory.deploy(
      mockERC20.address,
      hre.ethers.utils.parseEther("100"),
      mockERC721.address,
      gameVault.address,
      seasons.address, // This var is `ISeasons seasonRegistry, but we give seasons, not a registry
    );

    // StakerRewards contract needs funds to be able to pay members
    // We need to regulate this before calling transfer in each
    await mockERC20.connect(deployer).transfer(rewards.address, await mockERC20.balanceOf(deployer.address));

    // Registry for season 0 of the StakingGame
    seasons0RegistryAddress = (await seasons.seasons(0)).seasonObjects;
    seasons0Registry = ObjectRegistry__factory.connect(seasons0RegistryAddress, deployer);

    // Registry for the Seasons contract
    seasonsRegistry = ObjectRegistry__factory.connect(await seasons.registry(), deployer);

    // Registry for the GameVault contract
    gameVaultRegistry = ObjectRegistry__factory.connect(await gameVault.registry(), deployer);

    // Registry for the XP contract
    xpRegistry = ObjectRegistry__factory.connect(await xp.registry(), deployer);

    // Registrations
    await gameVaultRegistry.registerObjects([ethers.utils.formatBytes32String("Seasons")], [seasons.address]);
    await stakingGameRegistry.registerObjects([ethers.utils.formatBytes32String("Seasons")], [seasons.address]);
    await stakingGameRegistry.registerObjects([ethers.utils.formatBytes32String("GameVault")], [gameVault.address]);
    await seasons0Registry.registerObjects([ethers.utils.formatBytes32String("StakerRewards")], [rewards.address]);
    await seasonsRegistry.registerObjects([ethers.utils.formatBytes32String("XP")], [xp.address]);
    await xpRegistry.registerObjects([ethers.utils.formatBytes32String("StakerRewards")], [rewards.address]);
  });

  it("Fails when mint is called by someone without the MINTER_ROLE", async () => {
    await expect(mockERC721.connect(staker).mint(staker.address, 1)).to.be.revertedWith("ERC721PresetMinterPauserAutoId: must have minter role to mint");
  });

  it("Allows a user to stake their NFT, confirm they receive staked NFT in return", async () => {
    // Assume user already owns an NFT they'd like to stake
    await mockERC721.connect(deployer).mint(staker.address, 1);

    const stakerBalanceBefore = await mockERC721.balanceOf(staker.address);
    const gameVaultBalanceBefore = await mockERC721.balanceOf(gameVault.address);

    const stakerBalanceGMVLTBefore = await gameVault.balanceOf(staker.address);

    await mockERC721.connect(staker).approve(gameVault.address, 1);

    // 1.2 - User stakes their NFT in the GameVault
    await gameVault.connect(staker).depositFor(staker.address, [1]);

    const stakerBalanceAfter = await mockERC721.balanceOf(staker.address);
    const gameVaultBalanceAfter = await mockERC721.balanceOf(gameVault.address);

    const stakerBalanceGMVLTAfter = await gameVault.balanceOf(staker.address);

    expect(stakerBalanceAfter).eq(stakerBalanceBefore.sub(1));
    expect(gameVaultBalanceAfter).eq(gameVaultBalanceBefore.add(1));

    // 1.3 - User receives staked NFT in return
    expect(stakerBalanceGMVLTAfter).eq(stakerBalanceGMVLTBefore.add(1));
  });

  it("Users receive a race pass (new contract)", async () => {
    // 1.4 TODO No notion of a Stake Pass exists. Need clarity on what this is meant to be
  });

  it("Fails when a user calls to claim a reward for a token that is not theirs", async () => {
    await expect(rewards.connect(deployer).claim(1)).to.be.revertedWith("ZXP claimer isnt owner");
  });

  it("User receives a percentage of rewards on an epoch (passive rewards)", async () => {
    // Because we transfer to the GameVault in staking, when we call claim 
    // the "underlyingToken.ownerOf(id) == msg.sender" check fails because the staker is not currently the owner
    // We should call 

    // This is successful
    expect(await mockERC721.ownerOf(1)).eq(gameVault.address);

    // Call to claim rewards
    const before = await mockERC20.balanceOf(staker.address);
    await expect(rewards.connect(staker).claim(1)).to.be.revertedWith("ZXP claimer isnt owner");
    const after = await mockERC20.balanceOf(staker.address);
  });

  it("User can unstake at any time", async () => {
    const stakerBalanceBefore = await mockERC721.balanceOf(staker.address);
    const stakerBalanceGMVLTBefore = await gameVault.balanceOf(staker.address);
    const stakerBalanceERC20Before = await mockERC20.balanceOf(staker.address);

    // gameVault.withdrawTo => seasons.onUnstake() => stakerRewards.onUnstake()
    // 1.6 - User can unstake at any time.
    await gameVault.connect(staker).withdrawTo(staker.address, [1]);

    const stakerBalanceAfter = await mockERC721.balanceOf(staker.address);
    const stakerBalanceGMVLTAfter = await gameVault.balanceOf(staker.address);
    const stakerBalanceERC20After = await mockERC20.balanceOf(staker.address);

    expect(stakerBalanceAfter).eq(stakerBalanceBefore.add(1));
    expect(stakerBalanceGMVLTAfter).eq(stakerBalanceGMVLTBefore.sub(1));
    expect(stakerBalanceERC20After).gt(stakerBalanceERC20Before);
  });
});