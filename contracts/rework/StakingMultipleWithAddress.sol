// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { IERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

import { IERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract StakingMultipleWithADdress { // is ERC721Upgradeable {

  // The necessary details of a single staking implementation
  struct StakeConfig {
    IERC20Upgradeable rewardsToken;
    uint256 rewardsPerBlock;
  }


  // TODO
  // Configure as the StakingMultiple contract has but with nftContract as index into mappings
  // this would imply that each nft contract can only have one staking pool (configuration)
  // but not sure if we want to have this dynamic or not

  // Could likely still create a contract that uses NFT contract address to index
  // but also could allow for multiple configurations of the same NFT contract;
  
  /**
   * Imagine that a user could stake their Wheels NFT into pool A that returns X rewards per 
   * block and has no minimum time period for a stake, but they can also stake into pool B that 
   * returns X*2 rewards per block but mandates a minimum time period of 6 months. 
   */

  // This mapping would allow anyone to setup a staking configuration and would be heavily exploitable
  // because they could add any amount to rewardsPerBlock payout
  // mapping(address stakingOwner => StakeConfig config) public configs;
}