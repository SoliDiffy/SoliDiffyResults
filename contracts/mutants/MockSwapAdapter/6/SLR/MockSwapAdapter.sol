// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.8;

import {MintableERC20} from "";
import {ILendingPoolAddressesProvider} from "";
import {ISwapAdapter} from "";
import {ILendingPool} from "";
import {IERC20} from "";

contract MockSwapAdapter is ISwapAdapter {
  uint256 internal _amountToReturn;
  bool internal _tryReentrancy;
  ILendingPoolAddressesProvider public addressesProvider;

  event Swapped(address fromAsset, address toAsset, uint256 fromAmount, uint256 receivedAmount);

  constructor(ILendingPoolAddressesProvider provider) public {
    addressesProvider = provider;
  }

  function setAmountToReturn(uint256 amount) public {
    _amountToReturn = amount;
  }

  function setTryReentrancy(bool tryReentrancy) public {
    _tryReentrancy = tryReentrancy;
  }

  function executeOperation(
    address assetToSwapFrom,
    address assetToSwapTo,
    uint256 amountToSwap,
    address fundsDestination,
    bytes calldata params
  ) external override {
    params;
    IERC20(assetToSwapFrom).transfer(address(1), amountToSwap); // We don't want to keep funds here
    MintableERC20(assetToSwapTo).mint(_amountToReturn);
    IERC20(assetToSwapTo).approve(fundsDestination, _amountToReturn);

    if (_tryReentrancy) {
      ILendingPool(fundsDestination).repayWithCollateral(
        assetToSwapFrom,
        assetToSwapTo,
        address(1), // Doesn't matter, we just want to test the reentrancy
        1 ether, // Same
        address(1), // Same
        ""
      );
    }

    emit Swapped(assetToSwapFrom, assetToSwapTo, amountToSwap, _amountToReturn);
  }

  function burnAsset(IERC20 asset, uint256 amount) public {
    uint256 amountToBurn = (amount == type(uint256).max) ? asset.balanceOf(address(this)) : amount;
    asset.transfer(address(0), amountToBurn);
  }
}
