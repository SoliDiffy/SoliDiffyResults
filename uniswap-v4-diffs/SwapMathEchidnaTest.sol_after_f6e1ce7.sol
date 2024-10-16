// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.6.12;

import '../libraries/FixedPoint128.sol';
import '../libraries/SqrtTickMath.sol';
import '../libraries/SwapMath.sol';

contract SwapMathEchidnaTest {
    function requirePriceWithinBounds(uint160 price) private pure {
        require(price < SqrtTickMath.getSqrtRatioAtTick(SqrtTickMath.MAX_TICK)._x);
        require(price >= SqrtTickMath.getSqrtRatioAtTick(SqrtTickMath.MIN_TICK)._x);
    }

    function checkComputeSwapStepInvariants(
        uint160 sqrtPriceRaw,
        uint160 sqrtPriceTargetRaw,
        uint128 liquidity,
        uint256 amountInMax,
        uint24 feePips
    ) external pure {
        requirePriceWithinBounds(sqrtPriceRaw);
        requirePriceWithinBounds(sqrtPriceTargetRaw);
        require(feePips < 1e6);

        bool zeroForOne = sqrtPriceRaw >= sqrtPriceTargetRaw;

        require(amountInMax > 0);

        (
            FixedPoint96.uq64x96 memory sqrtQ,
            uint256 amountIn, /*uint256 amountOut*/
            ,
            uint256 feeAmount
        ) = SwapMath.computeSwapStep(
            FixedPoint96.uq64x96(sqrtPriceRaw),
            FixedPoint96.uq64x96(sqrtPriceTargetRaw),
            liquidity,
            amountInMax,
            feePips,
            zeroForOne
        );

        if (zeroForOne) {
            assert(sqrtQ._x <= sqrtPriceRaw);
            assert(sqrtQ._x >= sqrtPriceTargetRaw);
        } else {
            assert(sqrtQ._x >= sqrtPriceRaw);
            assert(sqrtQ._x <= sqrtPriceTargetRaw);
        }

        assert(amountIn + feeAmount <= amountInMax);
    }
}