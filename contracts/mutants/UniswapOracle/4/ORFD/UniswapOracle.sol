// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

// Referencing Uniswap Example Simple Oracle
// https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/examples/ExampleOracleSimple.sol

import "./IUniswapOracle.sol";
import "../refs/CoreRef.sol";
import "../external/UniswapV2OracleLibrary.sol";

/// @title Uniswap Oracle for ETH/USDC
/// @author Fei Protocol
/// @notice maintains the TWAP of a uniswap pair contract over a specified duration
contract UniswapOracle is IUniswapOracle, CoreRef {
    using Decimal for Decimal.D256;

    /// @notice the referenced uniswap pair contract
    IUniswapV2Pair public override pair;
    bool private isPrice0;

    /// @notice the previous cumulative price of the oracle snapshot
    uint256 public override priorCumulative;

    /// @notice the previous timestamp of the oracle snapshot
    uint32 public override priorTimestamp;

    Decimal.D256 private twap = Decimal.zero();

    /// @notice the window over which the initial price will "thaw" to the true peg price
    uint256 public override duration;

    uint256 private constant FIXED_POINT_GRANULARITY = 2**112;
    uint256 private constant USDC_DECIMALS_MULTIPLIER = 1e12; // to normalize USDC and ETH wei units

    /// @notice UniswapOracle constructor
    /// @param _core Fei Core for reference
    /// @param _pair Uniswap Pair to provide TWAP
    /// @param _duration TWAP duration
    /// @param _isPrice0 flag for using token0 or token1 for cumulative on Uniswap
    constructor(
        address _core,
        address _pair,
        uint256 _duration,
        bool _isPrice0
    ) CoreRef(_core) {
        pair = IUniswapV2Pair(_pair);
        // Relative to USD per ETH price
        isPrice0 = _isPrice0;

        duration = _duration;

        _init();
    }

    /// @notice updates the oracle price
    

    /// @notice determine if read value is stale
    /// @return true if read value is stale
    

    /// @notice read the oracle price
    /// @return oracle price
    /// @return true if price is valid
    /// @dev price is to be denominated in USD per X where X can be ETH, etc.
    /// @dev Can be innacurate if outdated, need to call `isOutdated()` to check
    

    /// @notice set a new duration for the TWAP window
    

    function _init() internal {
        (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 currentTimestamp
        ) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));

        priorTimestamp = currentTimestamp;
        priorCumulative = _getCumulative(price0Cumulative, price1Cumulative);
    }

    function _getCumulative(uint256 price0Cumulative, uint256 price1Cumulative)
        internal
        view
        returns (uint256)
    {
        return isPrice0 ? price0Cumulative : price1Cumulative;
    }
}
