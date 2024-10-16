// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PairActions#mint
/// @notice A contract that calls IUniswapV3PairActions#mint must implement this interface
interface IUniswapV3MintCallback {
    /// @notice Called on `msg.sender` after making updates to the position to allow the sender to pay the tokens
    ///     due for the minted liquidity
    /// @param amount0Owed the amount of token0 due to the pair for the minted liquidity
    /// @param amount1Owed the amount of token1 due to the pair for the minted liquidity
    /// @param data any data passed through by the caller via the IUniswapV3PairActions#mint call
    /// @dev The caller of this method must be checked to be a UniswapV3Pair deployed by the canonical factory
    /// TODO: user experience of the below note: https://github.com/Uniswap/uniswap-v3-core/issues/359
    /// @dev This method will not be called if the amount0Owed and amount1Owed are both 0
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external;
}