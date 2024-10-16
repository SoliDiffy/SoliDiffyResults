// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '@uniswap/lib/contracts/libraries/FullMath.sol';

import '@openzeppelin/contracts/math/SafeMath.sol';

import './TestERC20.sol';
import './TestUniswapV3Callee.sol';
import '../UniswapV3Pair.sol';
import '../UniswapV3Factory.sol';
import '../libraries/SafeCast.sol';
import '../libraries/SqrtTickMath.sol';

contract UniswapV3PairEchidnaTest {
    using SafeMath for uint256;
    using SafeCast for uint256;

    TestERC20 token0;
    TestERC20 token1;

    UniswapV3Factory factory;
    UniswapV3Pair pair;
    TestUniswapV3Callee payer;

    constructor() {
        payer = new TestUniswapV3Callee();
        factory = new UniswapV3Factory(address(this));
        initializeTokens();
        createNewPair(30);
        token0.approve(address(pair), uint256(-1));
        token1.approve(address(pair), uint256(-1));
    }

    function initializeTokens() private {
        TestERC20 tokenA = new TestERC20(uint256(-1));
        TestERC20 tokenB = new TestERC20(uint256(-1));
        (token0, token1) = (address(tokenA) < address(tokenB) ? (tokenA, tokenB) : (tokenB, tokenA));
    }

    function createNewPair(uint24 fee) private {
        pair = UniswapV3Pair(factory.createPair(address(token0), address(token1), fee));
    }

    function initializePair(uint160 sqrtPrice) public {
        pair.initialize(sqrtPrice);
    }

    function swapExact0For1(uint256 amount0In) external {
        require(amount0In > 1);
        require(amount0In < 1e18);
        token0.transfer(address(payer), amount0In);
        pair.swapExact0For1(amount0In, address(this));
    }

    function swapExact1For0(uint256 amount1In) external {
        require(amount1In > 1);
        require(amount1In < 1e18);
        token1.transfer(address(payer), amount1In);
        pair.swapExact1For0(amount1In, address(this));
    }

    function mint(
        address owner,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external {
        pair.mint(owner, tickLower, tickUpper, amount);
    }

    function burn(
        address to,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external {
        pair.burn(to, tickLower, tickUpper, amount);
    }

    function turnOnFee() external {
        pair.setFeeTo(address(this));
    }

    function turnOffFee() external {
        pair.setFeeTo(address(0));
    }

    function recoverToken0() external {
        pair.recover(address(token0), address(this), 1);
    }

    function recoverToken1() external {
        pair.recover(address(token1), address(this), 1);
    }

    function echidna_tickIsWithinBounds() external view returns (bool) {
        int24 tick = pair.tickCurrent();
        return (tick >= SqrtTickMath.MIN_TICK && tick < SqrtTickMath.MAX_TICK);
    }

    function echidna_priceIsWithinTickCurrent() external view returns (bool) {
        int24 tick = pair.tickCurrent();
        FixedPoint96.uq64x96 memory sqrtPriceCurrent = FixedPoint96.uq64x96(pair.sqrtPriceCurrent());
        return (SqrtTickMath.getSqrtRatioAtTick(tick)._x <= sqrtPriceCurrent._x &&
            SqrtTickMath.getSqrtRatioAtTick(tick + 1)._x > sqrtPriceCurrent._x);
    }

    function echidna_isInitialized() external view returns (bool) {
        return (address(token0) != address(0) &&
            address(token1) != address(0) &&
            address(factory) != address(0) &&
            address(pair) != address(0));
    }
}