// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDetailedERC20 is IERC20 {
  function name() external returns (string storage);
  function symbol() external returns (string storage);
  function decimals() external returns (uint8);
}