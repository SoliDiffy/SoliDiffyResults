// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import {IPoolManager} from './IPoolManager.sol';

/// @notice The PoolManager contract decides whether to invoke specific hooks by inspecting the leading bits
/// of the hooks contract address. For example, a 1 bit in the first bit of the address will
/// cause the 'before swap' hook to be invoked. See the Hooks library for the full spec.
interface IHooks {
    function beforeInitialize(
        address sender,
        IPoolManager.PoolKey calldata key,
        uint160 sqrtPriceX96
    ) external;

    function afterInitialize(
        address sender,
        IPoolManager.PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick
    ) external;

    function beforeModifyPosition(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata params
    ) external;

    function afterModifyPosition(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata params,
        IPoolManager.BalanceDelta calldata delta
    ) external;

    function beforeSwap(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.SwapParams calldata params
    ) external;

    function afterSwap(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        IPoolManager.BalanceDelta calldata delta
    ) external;

    function beforeDonate(
        address sender,
        IPoolManager.PoolKey calldata key,
        uint256 amount0,
        uint256 amount1
    ) external;

    function afterDonate(
        address sender,
        IPoolManager.PoolKey calldata key,
        uint256 amount0,
        uint256 amount1
    ) external;
}