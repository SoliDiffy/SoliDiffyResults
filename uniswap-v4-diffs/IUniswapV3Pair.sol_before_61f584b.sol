// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

import './pair/IUniswapV3PairImmutables.sol';
import './pair/IUniswapV3PairState.sol';
import './pair/IUniswapV3PairDerivedState.sol';
import './pair/IUniswapV3PairActions.sol';
import './pair/IUniswapV3PairOwnerActions.sol';
import './pair/IUniswapV3PairEvents.sol';

/// @title The interface for a Uniswap V3 Pair
/// @notice A Uniswap pair facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pair interface is broken up into many smaller pieces
interface IUniswapV3Pair is
    IUniswapV3PairImmutables,
    IUniswapV3PairState,
    IUniswapV3PairDerivedState,
    IUniswapV3PairActions,
    IUniswapV3PairOwnerActions,
    IUniswapV3PairEvents
{

}