// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

import './FullMath.sol';
import './SafeMath.sol';

import './SafeCast.sol';
import './FixedPoint96.sol';

library SqrtPriceMath {
    using SafeMath for uint256;
    using SafeCast for uint256;

    function isMulSafe(uint256 x, uint256 y) private pure returns (bool) {
        return (x * y) / x == y;
    }

    function isAddSafe(uint256 x, uint256 y) private pure returns (bool) {
        return x <= uint256(-1) - y;
    }

    function divRoundingUp(uint256 x, uint256 d) private pure returns (uint256) {
        // addition is safe because (uint256(-1) / 1) + (uint256(-1) % 1 > 0 ? 1 : 0) == uint256(-1)
        return (x / d) + (x % d > 0 ? 1 : 0);
    }

    function mulDivRoundingUp(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        return FullMath.mulDiv(x, y, d) + (mulmod(x, y, d) > 0 ? 1 : 0);
    }

    // calculate liquidity * sqrt(P) / (liquidity +- x * sqrt(P))
    // or, if this is impossible because of overflow,
    // liquidity / (liquidity / sqrt(P) +- x)
    function getNextPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) private pure returns (uint160) {
        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;

        if (
            isMulSafe(amount, sqrtPX96) &&
            (add ? isAddSafe(numerator1, amount * sqrtPX96) : numerator1 > amount * sqrtPX96)
        ) {
            uint256 denominator = add ? (numerator1 + amount * sqrtPX96) : (numerator1 - amount * sqrtPX96);
            return mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();
        }

        uint256 denominator = add ? (numerator1 / sqrtPX96).add(amount) : (numerator1 / sqrtPX96).sub(amount);
        require(denominator != 0, 'OUT');

        return divRoundingUp(numerator1, denominator).toUint160();
    }

    // calculate sqrt(P) +- y / liquidity
    function getNextPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) private pure returns (uint160) {
        // if we're adding (subtracting), rounding down requires rounding the quotient down (up)
        // in both cases, avoid a mulDiv for most inputs
        uint256 quotient =
            add
                ? (
                    amount <= uint160(-1)
                        ? (amount << FixedPoint96.RESOLUTION) / liquidity
                        : FullMath.mulDiv(amount, FixedPoint96.Q96, liquidity)
                )
                : (
                    amount <= uint160(-1)
                        ? divRoundingUp(amount << FixedPoint96.RESOLUTION, liquidity)
                        : mulDivRoundingUp(amount, FixedPoint96.Q96, liquidity)
                );

        return (add ? uint256(sqrtPX96).add(quotient) : uint256(sqrtPX96).sub(quotient)).toUint160();
    }

    function getNextPriceFromInput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountIn,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0, 'P');
        require(liquidity > 0, 'L');
        if (amountIn == 0) return sqrtPX96;

        // round to make sure that we don't pass the target price
        return
            zeroForOne
                ? getNextPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountIn, true)
                : getNextPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountIn, true);
    }

    function getNextPriceFromOutput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountOut,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0, 'P');
        require(liquidity > 0, 'L');
        if (amountOut == 0) return sqrtPX96;

        // round to make sure that we pass the target price
        return
            zeroForOne
                ? getNextPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountOut, false)
                : getNextPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountOut, false);
    }

    // calculate liquidity / sqrt(Q) - liquidity / sqrt(P), i.e.
    // liquidity * (sqrt(P) - sqrt(Q)) / (sqrt(P) * sqrt(Q))
    function getAmount0Delta(
        uint160 sqrtPX96, // square root of current price
        uint160 sqrtQX96, // square root of target price
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {
        assert(sqrtPX96 >= sqrtQX96);

        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
        uint256 numerator2 = sqrtPX96 - sqrtQX96;

        if (isMulSafe(sqrtPX96, sqrtQX96)) {
            uint256 denominator = uint256(sqrtPX96) * sqrtQX96;
            return
                roundUp
                    ? mulDivRoundingUp(numerator1, numerator2, denominator)
                    : FullMath.mulDiv(numerator1, numerator2, denominator);
        }

        return
            roundUp
                ? divRoundingUp(mulDivRoundingUp(numerator1, numerator2, sqrtPX96), sqrtQX96)
                : FullMath.mulDiv(numerator1, numerator2, sqrtPX96) / sqrtQX96;
    }

    // calculate liquidity * (sqrt(Q) - sqrt(P))
    function getAmount1Delta(
        uint160 sqrtPX96, // square root of current price
        uint160 sqrtQX96, // square root of target price
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {
        assert(sqrtQX96 >= sqrtPX96);

        return
            roundUp
                ? mulDivRoundingUp(liquidity, sqrtQX96 - sqrtPX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtQX96 - sqrtPX96, FixedPoint96.Q96);
    }

    // helpers to get signed deltas for use in setPosition
    function getAmount0Delta(
        uint160 sqrtPX96, // square root of current price
        uint160 sqrtQX96, // square root of target price
        int128 liquidity
    ) internal pure returns (int256 amount0) {
        return
            liquidity < 0
                ? -getAmount0Delta(sqrtPX96, sqrtQX96, uint128(-liquidity), false).toInt256()
                : getAmount0Delta(sqrtPX96, sqrtQX96, uint128(liquidity), true).toInt256();
    }

    function getAmount1Delta(
        uint160 sqrtPX96, // square root of current price
        uint160 sqrtQX96, // square root of target price
        int128 liquidity
    ) internal pure returns (int256 amount0) {
        return
            liquidity < 0
                ? -getAmount1Delta(sqrtPX96, sqrtQX96, uint128(-liquidity), false).toInt256()
                : getAmount1Delta(sqrtPX96, sqrtQX96, uint128(liquidity), true).toInt256();
    }
}