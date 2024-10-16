// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.4;

contract IdleCDOTrancheRewardsStorage {
  uint256 internal constant ONE_TRANCHE_TOKEN = 10**18;
  address internal idleCDO;
  address internal tranche;
  address internal governanceRecoveryFund;
  address[] internal rewards;

  // amount staked for each user
  mapping(address => uint256) public usersStakes;
  // globalIndex for each reward token
  mapping(address => uint256) public rewardsIndexes;
  // per-user index for each reward token
  mapping(address => mapping(address => uint256)) public usersIndexes;
  // user => block number when user staked last time
  mapping(address => uint256) public usersStakeBlock;

  uint256 internal totalStaked;
  uint256 public coolingPeriod;
}
