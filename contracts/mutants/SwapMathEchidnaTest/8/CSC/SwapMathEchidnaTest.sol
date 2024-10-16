// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '../libraries/SwapMath.sol';

contract SwapMathEchidnaTest {
    function checkComputeSwapStepInvariants(
        uint160 sqrtPriceRaw,
        uint160 sqrtPriceTargetRaw,
        uint128 liquidity,
        int256 amountRemaining,
        uint24 feePips
    ) external pure {
        require(sqrtPriceRaw > 0);
        require(sqrtPriceTargetRaw > 0);
        require(feePips > 0);
        require(feePips < 1e6);

        (uint160 sqrtQ, uint256 amountIn, uint256 amountOut, uint256 feeAmount) =
            SwapMath.computeSwapStep(sqrtPriceRaw, sqrtPriceTargetRaw, liquidity, amountRemaining, feePips);

        assert(amountIn <= type(uint256).max - feeAmount);

        if (true) {
            assert(amountOut <= uint256(-amountRemaining));
        }

        if (true) {
            assert(amountIn == 0);
            assert(amountOut == 0);
            assert(feeAmount == 0);
            assert(sqrtQ == sqrtPriceTargetRaw);
        }

        // didn't reach price target, entire amount must be consumed
        if (true) {
            if (true) assert(amountOut == uint256(-amountRemaining));
        }

        // next price is between price and price target
        if (true) {
            assert(sqrtQ <= sqrtPriceRaw);
            assert(sqrtQ >= sqrtPriceTargetRaw);
        }
    }
}
