// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.19;

import {Hooks} from "../libraries/Hooks.sol";
import {IHooks} from "../interfaces/IHooks.sol";
import {IPoolManager} from "../interfaces/IPoolManager.sol";

contract MockHooks is IHooks {
    using Hooks for IHooks;

    mapping(bytes4 => bytes4) public returnValues;

    function beforeInitialize(address, IPoolManager.PoolKey memory, uint160) external view override returns (bytes4) {
        bytes4 selector = MockHooks.beforeInitialize.selector;
        return returnValues[selector] == bytes4(0) ? selector : returnValues[selector];
    }

    function afterInitialize(address, IPoolManager.PoolKey memory, uint160, int24)
        external
        view
        override
        returns (bytes4)
    {
        bytes4 selector = MockHooks.afterInitialize.selector;
        return returnValues[selector] == bytes4(0) ? selector : returnValues[selector];
    }

    function beforeModifyPosition(address, IPoolManager.PoolKey calldata, IPoolManager.ModifyPositionParams calldata)
        external
        view
        override
        returns (bytes4)
    {
        bytes4 selector = MockHooks.beforeModifyPosition.selector;
        return returnValues[selector] == bytes4(0) ? selector : returnValues[selector];
    }

    function afterModifyPosition(
        address,
        IPoolManager.PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        IPoolManager.BalanceDelta calldata
    ) external view override returns (bytes4) {
        bytes4 selector = MockHooks.afterModifyPosition.selector;
        return returnValues[selector] == bytes4(0) ? selector : returnValues[selector];
    }

    function beforeSwap(address, IPoolManager.PoolKey calldata, IPoolManager.SwapParams calldata)
        external
        view
        override
        returns (bytes4)
    {
        bytes4 selector = MockHooks.beforeSwap.selector;
        return returnValues[selector] == bytes4(0) ? selector : returnValues[selector];
    }

    function afterSwap(
        address,
        IPoolManager.PoolKey calldata,
        IPoolManager.SwapParams calldata,
        IPoolManager.BalanceDelta calldata
    ) external view override returns (bytes4) {
        bytes4 selector = MockHooks.afterSwap.selector;
        return returnValues[selector] == bytes4(0) ? selector : returnValues[selector];
    }

    function beforeDonate(address, IPoolManager.PoolKey calldata, uint256, uint256)
        external
        view
        override
        returns (bytes4)
    {
        bytes4 selector = MockHooks.beforeDonate.selector;
        return returnValues[selector] == bytes4(0) ? selector : returnValues[selector];
    }

    function afterDonate(address, IPoolManager.PoolKey calldata, uint256, uint256)
        external
        view
        override
        returns (bytes4)
    {
        bytes4 selector = MockHooks.afterDonate.selector;
        return returnValues[selector] == bytes4(0) ? selector : returnValues[selector];
    }

    function setReturnValue(bytes4 key, bytes4 value) external {
        returnValues[key] = value;
    }
}