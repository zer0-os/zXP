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
  Staking,
  StakingMultiple,
  XP,
} from "../typechain";
import { mine } from "@nomicfoundation/hardhat-network-helpers";
import {
  CONFIG_NOT_SET,
  INVALID_TOKEN_ID,
  ONLY_NFT_OWNER,
  ONLY_SNFT_OWNER,
} from "./helpers/errors";
import { StakingConfig } from "./helpers/types";
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

  describe("Rework", () => {
    let deployer : SignerWithAddress;
    let staker : SignerWithAddress;
    
    let stakingContract : Staking;

    let mockERC20 : MockERC20;
    let mockERC721 : MockERC721;

    type StakingConfig = {
      stakingToken : string;
      rewardsToken : string;
      rewardsPerBlock : string;
    }

    let config : StakingConfig;
    let tokenId : number;

    before(async () => {
      [
        deployer,
        staker,
      ] = await hre.ethers.getSigners();

      const mockERC20Factory = await hre.ethers.getContractFactory("MockERC20");
      mockERC20 = await mockERC20Factory.deploy("MEOW", "MEOW");

      const mockERC721Factory = await hre.ethers.getContractFactory("MockERC721");
      mockERC721 = await mockERC721Factory.deploy("WilderWheels", "WW", "0://wheels-base");

      config = {
        stakingToken : mockERC721.address,
        rewardsToken : mockERC20.address,
        rewardsPerBlock : hre.ethers.utils.parseEther("100").toString(),
      }

      const stakingFactory = await hre.ethers.getContractFactory("Staking");
      stakingContract = await stakingFactory.deploy("StakingNFT", "SNFT", config);

      // Give staking contract balance to pay rewards (maybe house these in a vault of some kind)
      mockERC20.connect(deployer).transfer(stakingContract.address, hre.ethers.utils.parseEther("1000000"));

      tokenId = 1;
    });

    it("Can stake an NFT", async () => {
      await mockERC721.connect(deployer).mint(staker.address, tokenId);

      await mockERC721.connect(staker).approve(stakingContract.address, tokenId);

      await stakingContract.connect(staker).stake(tokenId);

      // User has staked their NFT and gained an SNFT
      expect(await mockERC721.balanceOf(staker.address)).to.eq(0);
      expect(await stakingContract.balanceOf(staker.address)).to.eq(1);
    });

    it("Can claim rewards on a staked token", async () => {
      const blocks = 10;
      await mine(blocks);

      const balanceBefore = await mockERC20.balanceOf(staker.address);

      await stakingContract.connect(staker).claim(tokenId);

      const rewardsPerBlock = (await stakingContract.config()).rewardsPerBlock;

      const balanceAfter = await mockERC20.balanceOf(staker.address);

      // We do blocks + 1 because the claim call is executed on a new block in testing
      expect(balanceAfter).to.be.gt(balanceBefore.add(rewardsPerBlock.mul(blocks + 1)));
    });

    it("Can unstake a token", async () => {
      const blocks = 10;
      await mine(blocks);

      const balanceBefore = await mockERC20.balanceOf(staker.address);

      await stakingContract.connect(staker).unstake(tokenId);

      const rewardsPerBlock = (await stakingContract.config()).rewardsPerBlock;

      const balanceAfter = await mockERC20.balanceOf(staker.address);

      // We do blocks + 1 because the unstake call is executed on a new block in testing
      expect(balanceAfter).to.be.gt(balanceBefore.add(rewardsPerBlock.mul(blocks + 1)));
    });

    it("Can call burn on a token that is not owned by the contract?", async () => {
      // first mint and stake a token, then call to unstake it and see if burn succeeds
      

      // const blocks = 10;
      // await mine(blocks);

      // // Staker will now have given up NFT but received an SNFT
      // // does "_burn" succeed?
      // const balanceBefore = await mockERC20.balanceOf(staker.address);

      // await stakingContract.connect(staker).unstake(tokenId);

      // const rewardsPerBlock = (await stakingContract.config()).rewardsPerBlock;

      // const balanceAfter = await mockERC20.balanceOf(staker.address);

      // // We do blocks + 1 because the unstake call is executed on a new block in testing
      // expect(balanceAfter).to.be.gt(balanceBefore.add(rewardsPerBlock.mul(blocks + 1)));

      // // cannot unstake twice
      // await expect(stakingContract.connect(staker).unstake(tokenId)).to.be.reverted;
    });
  });

  describe.only("Rework StakeMultiple", async () => {
    let deployer : SignerWithAddress;
    let staker : SignerWithAddress;
    let notStaker : SignerWithAddress;

    let stakingContract : StakingMultiple;

    let mockERC20 : MockERC20;
    let mockERC721 : MockERC721;

    let defaultConfig : StakingConfig;
    let defaultStakingId : string;

    let defaultStake : Function;
    let transfer : Function;

    const defaultTokenId : number = 1;

    before(async () => {
      [
        deployer,
        staker,
        notStaker,
      ] = await hre.ethers.getSigners();

      const mockERC20Factory = await hre.ethers.getContractFactory("MockERC20");
      mockERC20 = await mockERC20Factory.deploy("MEOW", "MEOW");

      const mockERC721Factory = await hre.ethers.getContractFactory("MockERC721");
      mockERC721 = await mockERC721Factory.deploy("WilderWheels", "WW", "0://wheels-base");

      const stakingFactory = await hre.ethers.getContractFactory("StakingMultiple");
      stakingContract = await hre.upgrades.deployProxy(
        stakingFactory,
        [
          "StakingNFT",
          "SNFT",
        ]) as StakingMultiple;

      // Create a default configuration
      defaultConfig = {
        stakingToken : mockERC721.address,
        rewardsToken : mockERC20.address,
        rewardsPerBlock : hre.ethers.utils.parseEther("100").toString(),
      }

      // Create the initial default staking configuration
      await stakingContract.connect(deployer).setConfig(defaultConfig);
      defaultStakingId = await stakingContract.getStakingId(defaultConfig);

      await mockERC20.connect(deployer).transfer(stakingContract.address, hre.ethers.utils.parseEther("9000000000"));
    });

    // beforeEach(async () => {
      // Create default stake function
      // defaultStake = async () => {
      // };

      // Give staking contract balance to pay rewards
      // transfer = async () => {
        // TODO maybe house these in a vault of some kind instead of the staking contract
        // TODO want to not redploy each test, but because we require the `stakingContract.address`
        // we have this here as a callable function that we only invoke once
      // };

      // transferFunc
    // });

    // it("An admin can configure a contract for staking correctly", async () => {
    //   const config = await stakingContract.configs(defaultStakingId);

    //   expect(config.stakingToken).to.eq(defaultConfig.stakingToken);
    //   expect(config.rewardsToken).to.eq(defaultConfig.rewardsToken);
    //   expect(config.rewardsPerBlock).to.eq(defaultConfig.rewardsPerBlock);
    // });

    it("User can stake an NFT", async () => {
      // await defaultStake();
      await mockERC721.connect(deployer).mint(staker.address, defaultTokenId);
      await mockERC721.connect(staker).approve(stakingContract.address, defaultTokenId);
      await stakingContract.connect(staker).stake(defaultStakingId, defaultTokenId);

      // User has staked their NFT and gained an SNFT
      expect(await mockERC721.balanceOf(staker.address)).to.eq(0);
      expect(await stakingContract.balanceOf(staker.address)).to.eq(1);
    });

    it("User can claim rewards on a staked token", async () => {
      // Expect token is staked
      expect(await stakingContract.stakedOrClaimedAt(defaultTokenId)).to.not.eq(0);

      const balanceBefore = await mockERC20.balanceOf(staker.address);

      await stakingContract.connect(staker).claim(defaultStakingId, defaultTokenId);

      const balanceAfter = await mockERC20.balanceOf(staker.address);

      const rewardsPerBlock = (await stakingContract.configs(defaultStakingId)).rewardsPerBlock;

      expect(balanceAfter).to.eq(balanceBefore.add(rewardsPerBlock));
      expect(await stakingContract.stakedOrClaimedAt(defaultTokenId)).to.eq(await hre.ethers.provider.getBlockNumber());
    });

    it("User can unstake a token", async () => {
      // await defaultStake(); // why not just add this in beforeEach regularly, not as a function?
      // const blocks = 10;
      // await mine(blocks);

      const balanceBefore = await mockERC20.balanceOf(staker.address);

      await stakingContract.connect(staker).unstake(defaultStakingId, defaultTokenId);

      const balanceAfter = await mockERC20.balanceOf(staker.address);

      const rewardsPerBlock = (await stakingContract.configs(defaultStakingId)).rewardsPerBlock;

      // We do + 1 because the unstake call is executed on a new block in testing
      expect(balanceAfter).to.eq(balanceBefore.add(rewardsPerBlock));
      expect(await stakingContract.stakedOrClaimedAt(defaultTokenId)).to.eq(0);
    });

    it("Fails when you try to stake for a pool thats not setup by the admin", async () => {
      const config = {
        stakingToken : mockERC721.address,
        rewardsToken : mockERC20.address,
        rewardsPerBlock : hre.ethers.utils.parseEther("1").toString(),
        // Difference in rewardsPerBlock will create new stakingId
      }

      const stakingId = await stakingContract.getStakingId(config);

      await expect(
          stakingContract.connect(staker).stake(stakingId, defaultTokenId))
          .to.be.revertedWith(CONFIG_NOT_SET);
    });

    it("Fails when you try to claim for a pool thats not setup by the admin", async () => {
      // User wouldn't have a valid tokenId in this scenario because they only get it from staking
      // So fails with `ERC721: invalid token id`
      const config = {
        stakingToken : mockERC721.address,
        rewardsToken : mockERC20.address,
        rewardsPerBlock : hre.ethers.utils.parseEther("3").toString(),
        // Difference in rewardsPerBlock will create new stakingId
      }

      const stakingId = await stakingContract.getStakingId(config);

      await expect(
          stakingContract.connect(staker).claim(stakingId, defaultTokenId))
          .to.be.revertedWith(INVALID_TOKEN_ID);
    });

    it("Fails when you try to unstake for a pool thats not setup by the admin", async () => {
      // User wouldn't have a valid tokenId in this scenario because they only get it from staking
      // So fails with `ERC721: invalid token id`
      const config = {
        stakingToken : mockERC721.address,
        rewardsToken : mockERC20.address,
        rewardsPerBlock : hre.ethers.utils.parseEther("3").toString(),
        // Difference in rewardsPerBlock will create new stakingId
      }

      const stakingId = await stakingContract.getStakingId(config);

      await expect(
          stakingContract.connect(staker).unstake(stakingId, defaultTokenId))
          .to.be.revertedWith(INVALID_TOKEN_ID);
    });

    it("Fails when you try to stake an already staked token", async () => {
      // First we must approve the contract again before a stake
      await mockERC721.connect(staker).approve(stakingContract.address, defaultTokenId);
      
      // Stake token
      await stakingContract.connect(staker).stake(defaultStakingId, defaultTokenId);

      // Try to stake it again
      // Fails because the caller no longer owns the NFT to be staked
      await expect(
          stakingContract.connect(staker).stake(defaultStakingId, defaultTokenId))
          .to.be.revertedWith(ONLY_NFT_OWNER);
    });

    it("Fails when you try to claim rewards on an unstaked token", async () => {
      // Unstake token
      await stakingContract.connect(staker).unstake(defaultStakingId, defaultTokenId);

      // Fails because the caller no longer owns the NFT to be claimed
      await expect(
          stakingContract.connect(staker).claim(defaultStakingId, defaultTokenId))
          .to.be.revertedWith(INVALID_TOKEN_ID);
    });

    it("Fails when you try to unstake an already unstaked token", async () => {
      // Fails because the caller no longer owns the NFT to be unstaked
      await expect(
          stakingContract.connect(staker).unstake(defaultStakingId, defaultTokenId))
          .to.be.revertedWith(INVALID_TOKEN_ID);
    });

    it("Fails when staking a token that is not owned by the caller", async () => {
      // Assume that the correct staker called to approve already
      // Incorrect staker calling to approve a token thats not theirs would fail
      await mockERC721.connect(staker).approve(stakingContract.address, defaultTokenId);
      
      // Stake token
      await expect(
        stakingContract.connect(notStaker).stake(defaultStakingId, defaultTokenId))
        .to.be.revertedWith(ONLY_NFT_OWNER);
    });

    it("Fails when unstaking a token that is not owned by the caller", async () => {
      // Assume that the correct staker called to approve already
      // Incorrect staker calling to approve a token thats not theirs would fail
      await stakingContract.connect(staker).stake(defaultStakingId, defaultTokenId);

      // Unstake token
      // Because the SNFT token is only given when a user stakes, 
      await expect(
        stakingContract.connect(notStaker).unstake(defaultStakingId, defaultTokenId))
        .to.be.revertedWith(ONLY_SNFT_OWNER);
    });

    // valid stake in one pool, try to claim / unstake in another pool

    // cannot claim or unstake an nft that is not staked

    // allows owner of SNFT to call to unstake

    // fails to stake when an NFT is not owned by the user
    // fails to claim when a SNFT is not owned by the user
    // fails to unstake when a SNFT is not owned by the user

    // fails to stake when not setup by admin

    // appropriate fails for when not admin (cannot setConfig or update existing configs)
    // 
  });
});