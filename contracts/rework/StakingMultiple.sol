// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { IERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

// TODO idea, maybe receival of SNFT is what triggers unstake?
// import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// ERC721Wrapper makes the underlying token to be immutable, but we want to be able to change it

contract StakingMultiple is ERC721Upgradeable {

  // The necessary details of a single staking implementation
  struct StakeConfig { // TODO move to interface when one exists
    IERC721Upgradeable stakingToken; // should these types be upgradeable? does it matter?
    IERC20Upgradeable rewardsToken;
    uint256 rewardsPerBlock; // including this allows for multiple staking configurations for the same token
  }

  // Only the admin of the contract
  modifier onlyAdmin() {
    require(msg.sender == admin, "only admin");
    _;
  }

  // Only the owner of the representative stake NFT
  modifier onlySNFTOwner(uint256 tokenId) {
    require(
      ownerOf(tokenId) == msg.sender,
      "Caller is not the owner of the representative stake token"
    );
    _;
  }

  // Only the original NFT owner
  modifier onlyNFTOwner(bytes32 stakingId, uint256 tokenId) {
    require(
      configs[stakingId].stakingToken.ownerOf(tokenId) == msg.sender,
      "Caller is not the original staker"
    );
    _;
  }

  // Staking can only occur if the admin has set a staking configuration
  modifier onlyConfigured(bytes32 stakingId) {
    require(
      // TODO update this to check all configured variables in a stake config,
      // not just the staking token, otherwise will fail because we want
      // to allow multiple pools of the same staking token
      address(configs[stakingId].stakingToken) != address(0),
      "NFT Contract not configured for staking"
    );
    _;
  }

  // The operator of this contract
  address admin; // so one staking contract per org? can we do one contract in total?

  // Mapping of staking configurations
  mapping(bytes32 stakingId => StakeConfig config) public configs;

  // Mapping to track when a token was last accessed by the system
  mapping(uint256 tokenId => uint256 blockNumber) public stakedOrClaimedAt;

  // We track the original staker of the NFT to allow the SNFT to be transferable
  // and still return the original NFT to the original staker on unstake
  mapping(uint256 tokenId => address staker) public originalStakers;

  function initialize(
    string memory name,
    string memory symbol
  ) public initializer {
    admin = msg.sender;
    __ERC721_init(name, symbol);
  }

  // add setupStakingBulk to allow multiple staking configurations to be set at once
  function setConfig(
    StakeConfig memory _config
  ) public onlyAdmin {
    
    // TODO we don't save this which could be a vulnerability
    // the `onlyConfigured` modifier just checks the value of the stakingId given to the function
    // not that we have created one, and so it could be hashed off chain regardless of if one has been set
    // then staked, even if the admin hasn't set it up to do so yet.
    bytes32 stakingId =
      keccak256(
        abi.encodePacked( // 0 checks here?
          _config.stakingToken,
          _config.rewardsToken,
          _config.rewardsPerBlock
          // should we include rewards per block in ID?
          // if we do, other staking configs can be set the same with different rewards per block
          // but we dont have to include it in the ID to find it,
          // we can still find it with id => config.rewardsPerBlock
          // and if we don't include it, a ERC721 and ERC20 pair is unique
          // so a staking pool can is 1:1 for a contract
        )
      );

    require(
      // TODO if we want to allow multiple pools of the same staking token
      // this will fail, need to update to check all values don't conflict
      // check mapping that this unique stake ID doesnt exist, when we create that mapping
      address(configs[stakingId].stakingToken) == address(0),
      "Staking configuration already exists"
    );

    configs[stakingId] = _config;
    // emit ConfigSet(stakingToken, rewardsToken, rewardsPerBlock);
  }

  function getStakingId(
    StakeConfig memory _config
  ) public pure returns (bytes32) {
    return keccak256(
      abi.encodePacked(
        _config.stakingToken,
        _config.rewardsToken,
        _config.rewardsPerBlock
      )
    );
  }

  // unguarded functions
  // getAdmin
  // isStaking or configurationExists for a token contract
  // getPendingRewards(bytes32 stakingId, uint256 tokenId)
  // getRewardsPerBlock(bytes32 stakingId)
  // getStakingToken(bytes32 stakingId)
  // getRewardsToken(bytes32 stakingId)

  // onlyAdmin functions
  // setConfig => create new config

  // a change to an existing config would create a new stakingId
  // so just make a new staking config instead?
  // setRewardsPerBlock => edit existing config
  // setStakingToken => edit existing config
  // setRewardsToken => edit existing config

  // stake
  function stake(
    bytes32 stakingId,
    uint256 tokenId
  ) public onlyConfigured(stakingId) onlyNFTOwner(stakingId, tokenId) {
    require(
      stakedOrClaimedAt[tokenId] == 0,
      "Token is already staked"
    );
    
    // Mark the staking block number
    stakedOrClaimedAt[tokenId] = block.number;

    // Transfer the staker's NFT
    configs[stakingId].stakingToken.transferFrom(msg.sender, address(this), tokenId);

    // Mark the user as the original staker for return in unstake
    originalStakers[tokenId] = msg.sender;

    // Mint the owner an SNFT
    _mint(msg.sender, tokenId);
    // emit Staked(msg.sender, tokenId, stakingId);
  }

  // unstake
  function unstake(
    bytes32 stakingId,
    uint256 tokenId
  ) public onlySNFTOwner(tokenId) {
    require(
      stakedOrClaimedAt[tokenId] != 0,
      "Token is not currently staked"
    );

    // Return NFT to the original staker
    configs[stakingId].stakingToken.transferFrom(address(this), originalStakers[tokenId], tokenId);

    // Burn the SNFT
    _burn(tokenId);

    // Calculate the rewards
    uint256 rewards = configs[stakingId].rewardsPerBlock * (block.number - stakedOrClaimedAt[tokenId]);

    // Update staked mappings
    stakedOrClaimedAt[tokenId] = 0;
    originalStakers[tokenId] = address(0);

    // Transfer the rewards
    configs[stakingId].rewardsToken.transfer(msg.sender, rewards);
    // emit Unstaked(msg.sender, tokenId, stakingId, rewards);
  }

  // claim
  function claim(
    bytes32 stakingId,
    uint256 tokenId
  ) public onlySNFTOwner(tokenId) {
    require(
      stakedOrClaimedAt[tokenId] != 0,
      "Token is not currently staked"
    );

    // Calculate and transfer rewards
    uint256 rewards = configs[stakingId].rewardsPerBlock * (block.number - stakedOrClaimedAt[tokenId]);
    configs[stakingId].rewardsToken.transfer(msg.sender, rewards);

    // Update to most recently claimed block
    stakedOrClaimedAt[tokenId] = block.number;
    // emit Claimed(msg.sender, tokenId, stakingId, rewards);
  }

  function deleteConfig(StakeConfig _config) public onlyAdmin {
    bytes32 stakingId = getStakingId(_config);
    delete configs[stakingId];
  }
}