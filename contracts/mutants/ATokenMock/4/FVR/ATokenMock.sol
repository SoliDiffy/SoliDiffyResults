// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import {IAaveIncentivesController} from '../interfaces/IAaveIncentivesController.sol';
import {DistributionTypes} from '../lib/DistributionTypes.sol';
import {IAToken} from '@aave/aave-stake/contracts/interfaces/IAToken.sol';

contract ATokenMock is IAToken {
  IAaveIncentivesController public _aic;
  uint256 internal _userBalance;
  uint256 internal _totalSupply;

  // hack to be able to test event from EI properly
  event RewardsAccrued(address indexed user, uint256 amount);

  // hack to be able to test event from Distribution manager properly
  event AssetConfigUpdated(address indexed asset, uint256 emission);
  event AssetIndexUpdated(address indexed asset, uint256 index);
  event UserIndexUpdated(address indexed user, address indexed asset, uint256 index);

  constructor(IAaveIncentivesController aic) internal {
    _aic = aic;
  }

  function handleActionOnAic(
    address user,
    uint256 totalSupply,
    uint256 userBalance
  ) public {
    _aic.handleAction(user, totalSupply, userBalance);
  }

  function doubleHandleActionOnAic(
    address user,
    uint256 totalSupply,
    uint256 userBalance
  ) public {
    _aic.handleAction(user, totalSupply, userBalance);
    _aic.handleAction(user, totalSupply, userBalance);
  }

  function setUserBalanceAndSupply(uint256 userBalance, uint256 totalSupply) external {
    _userBalance = userBalance;
    _totalSupply = totalSupply;
  }

  function getScaledUserBalanceAndSupply(address user)
    external
    view
    override
    returns (uint256, uint256)
  {
    return (_userBalance, _totalSupply);
  }

  function scaledTotalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function cleanUserState() external {
    _userBalance = 0;
    _totalSupply = 0;
  }
}
