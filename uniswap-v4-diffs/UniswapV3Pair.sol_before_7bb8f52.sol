// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.8;
pragma experimental ABIEncoderV2;

import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';
import '@uniswap/lib/contracts/libraries/Babylonian.sol';

import './libraries/FeeVoting.sol';
import './libraries/SafeMath.sol';
import './libraries/FixedPointExtra.sol';
import './libraries/TickMath.sol';
import './libraries/PriceMath.sol';

import './interfaces/IUniswapV3Pair.sol';
import './interfaces/IUniswapV3Factory.sol';
import './interfaces/IUniswapV3Callee.sol';

contract UniswapV3Pair is IUniswapV3Pair {
    using SafeMath for uint;
    using SafeMathUint112 for uint112;
    using SafeMathInt112 for int112;
    using FixedPoint for FixedPoint.uq112x112;
    using FixedPoint for FixedPoint.uq144x112;
    using FixedPointExtra for FixedPoint.uq112x112;

    uint112 public constant override MINIMUM_LIQUIDITY = 10**3;
    uint16 public constant MAX_FEEVOTE = 6000; // 60 bps
    uint16 public constant MIN_FEEVOTE =    0; // 0 bps

    address public immutable override factory;
    address public immutable override token0;
    address public immutable override token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public override price0CumulativeLast;
    uint public override price1CumulativeLast;
    uint public override kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint112 public virtualSupply;  // current virtual supply

    int16 public currentTick; // the current tick for the token0 price (i.e. token1/token0), rounded down
    
    // these only have relative meaning, not absolute—their value depends on when the tick is initialized
    struct TickInfo {
        // seconds spent while pool was on other side of this tick (from the current price)
        uint32 secondsGrowthOutside;
        // growth due to fees while pool was on the other side of this tick (from the current price)
        FixedPoint.uq112x112 growthOutside;
    }
    mapping (int16 => TickInfo) tickInfos; // mapping from tick indexes to information about that tick
    mapping (int16 => int112) deltas;      // mapping from tick indexes to amount of token0 kicked in or out when tick is crossed going from left to right (token0 price going up)

    uint112 public totalFeeVote;
    FeeVoting.Aggregate aggregateFeeVote;
    mapping (int16 => FeeVoting.Aggregate) deltaFeeVotes; // mapping from tick indexes to amount of token0 kicked in or out when tick is crossed

    struct Position {
        // liquidity is adjusted virtual liquidity tokens (sqrt(reserve0 * reserve1)), not counting fees since last sync
        // these units do not increase over time with accumulated fees. it is always sqrt(reserve0 * reserve1)
        // liquidity stays the same if pinged with 0 as liquidityDelta, because accumulated fees are collected when synced
        uint112 liquidity;
        // lastNormalizedLiquidity is (liquidity / growthInRange) as of last sync
        // lastNormalizedLiquidity is smaller than liquidity if any fees have previously been earned in the range
        // and gets even smaller when pinged if any fees were earned in the range
        uint112 lastNormalizedLiquidity;
        uint16 feeVote; // this provider's vote for fee, in 1/100ths of a bp
    }
    // TODO: is this the best way to map (address, int16, int16) to position?
    mapping (bytes32 => Position) positions;

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'UniswapV3: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves()
        public
        override
        view
        returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    // returns g = sqrt(reserve0 * reserve1) / virtual supply
    function getG() public view returns (FixedPoint.uq112x112 memory g) {
        uint rootK = Babylonian.sqrt(uint(reserve0) * reserve1);
        g = FixedPoint.encode(uint112(rootK)).div(virtualSupply);
    }

    function getGrowthBelow(int16 tickIndex, FixedPoint.uq112x112 memory g)
        public
        view
        returns (FixedPoint.uq112x112 memory growthBelow)
    {
        growthBelow = tickInfos[tickIndex].growthOutside;
        // the range is currently active
        if (currentTick < tickIndex) {
            growthBelow = g.uqdiv112(growthBelow);
        }
    }

    function getGrowthAbove(int16 tickIndex, FixedPoint.uq112x112 memory g)
        public
        view
        returns (FixedPoint.uq112x112 memory growthAbove)
    {
        growthAbove = tickInfos[tickIndex].growthOutside;
        // this range is currently active
        if (currentTick >= tickIndex) {
            return g.uqdiv112(growthAbove);
        }
    }

    // gets the growth in g within a particular range
    // this only has relative meaning, not absolute
    // TODO: simpler or more precise way to compute this?
    function getGrowthInside(int16 lowerTick, int16 upperTick)
        public
        view
        returns (FixedPoint.uq112x112 memory growth)
    {
        FixedPoint.uq112x112 memory g = getG();
        FixedPoint.uq112x112 memory growthBelow = getGrowthBelow(lowerTick, g);
        FixedPoint.uq112x112 memory growthAbove = getGrowthAbove(upperTick, g);
        growth = growthAbove.uqmul112(growthBelow).reciprocal().uqmul112(g);
    }

    // given an amount of liquidity and a price, return the value of that liquidity at the price
    function getBalancesAtPrice(int112 liquidity, FixedPoint.uq112x112 memory price) 
        private
        pure
        returns (int112 balance0, int112 balance1)
    {
        balance0 = price.reciprocal().sqrt().smul112(liquidity);
        balance1 = price.smul112(balance0);
    }

    // given an amount of liquidity and a tick, return the value of that liquidity at the price determined by the tick
    function getBalancesAtTick(int112 liquidity, int16 tick) private pure returns (int112 balance0, int112 balance1) {
        // this is a lie - one of them should be near infinite
        // TODO ensure this is safe and the right thing to do
        if (tick == TickMath.MIN_TICK || tick == TickMath.MAX_TICK) {
            return (0, 0);
        }
        return getBalancesAtPrice(liquidity, TickMath.getPrice(tick));
    }

    constructor(address _token0, address _token1) public {
        factory = msg.sender;
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint112 _oldReserve0, uint112 _oldReserve1, uint112 _newReserve0, uint112 _newReserve1) private {
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _oldReserve0 != 0 && _oldReserve1 != 0) {
            // + overflow is desired
            price0CumulativeLast += FixedPoint.encode(_oldReserve1).div(_oldReserve0).mul(timeElapsed).decode144();
            price1CumulativeLast += FixedPoint.encode(_oldReserve0).div(_oldReserve1).mul(timeElapsed).decode144();
        }
        reserve0 = _newReserve0;
        reserve1 = _newReserve1;
        blockTimestampLast = blockTimestamp;
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV3Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        uint112 _virtualSupply = virtualSupply;
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Babylonian.sqrt(uint(_reserve0) * _reserve1);
                uint rootKLast = Babylonian.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = uint(_virtualSupply).mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint112 liquidity = uint112(numerator / denominator);
                    if (liquidity > 0) {
                        Position storage position = getPosition(feeTo, 0, 0);
                        position.liquidity = position.liquidity + liquidity;
                        virtualSupply = _virtualSupply + liquidity;
                    }
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function initialAdd(uint112 amount0, uint112 amount1, int16 startingTick, uint16 feeVote) external override lock returns (uint112 liquidity) {
        require(virtualSupply == 0, "UniswapV3: ALREADY_INITIALIZED");
        require(feeVote >= MIN_FEEVOTE && feeVote <= MAX_FEEVOTE, "UniswapV3: INVALID_FEE_VOTE");
        FixedPoint.uq112x112 memory price = FixedPoint.encode(amount1).div(amount0);
        require(price._x > TickMath.getPrice(startingTick)._x && price._x < TickMath.getPrice(startingTick + 1)._x);
        bool feeOn = _mintFee(0, 0);
        liquidity = uint112(Babylonian.sqrt(uint(amount0) * amount1).sub(MINIMUM_LIQUIDITY));
        setPosition(address(0), TickMath.MIN_TICK, TickMath.MAX_TICK, Position({
            liquidity: MINIMUM_LIQUIDITY,
            lastNormalizedLiquidity: MINIMUM_LIQUIDITY,
            feeVote: feeVote
        }));
        setPosition(msg.sender, TickMath.MIN_TICK, TickMath.MAX_TICK, Position({
            liquidity: liquidity,
            lastNormalizedLiquidity: liquidity,
            feeVote: feeVote
        }));
        uint112 totalLiquidity = liquidity + MINIMUM_LIQUIDITY;
        virtualSupply = totalLiquidity;
        aggregateFeeVote = FeeVoting.Aggregate({
            numerator: int112(feeVote).mul(int112(totalLiquidity)),
            denominator: int112(totalLiquidity)
        });
        uint112 _reserve0 = amount0;
        uint112 _reserve1 = amount1;
        _update(0, 0, _reserve0, _reserve1);
        currentTick = startingTick;
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amount0);
        TransferHelper.safeTransferFrom(token1, msg.sender, address(this), amount1);
        if (feeOn) kLast = uint(_reserve0).mul(_reserve1);
        emit SetPosition(address(0), int112(MINIMUM_LIQUIDITY), TickMath.MIN_TICK, TickMath.MAX_TICK, feeVote);
        emit SetPosition(msg.sender, int112(liquidity), TickMath.MIN_TICK, TickMath.MAX_TICK, feeVote);
    }

    // called when adding or removing liquidity that is within range
    function updateVirtualLiquidity(int112 liquidity, FeeVoting.Aggregate memory deltaFeeVote)
        private
        returns (int112 virtualAmount0, int112 virtualAmount1)
    {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        (virtualAmount0, virtualAmount1) = getBalancesAtPrice(liquidity, FixedPoint.encode(reserve1).div(reserve0));
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint112 _virtualSupply = virtualSupply; // gas savings, must be defined here since virtualSupply can update in _mintFee
        // price doesn't change, so no need to update oracle
        virtualSupply = _virtualSupply.add(int112(int(virtualAmount0) * int(_virtualSupply) / int(reserve0)));
        _reserve0 = _reserve0.add(virtualAmount0);
        _reserve1 = _reserve1.add(virtualAmount1);
        (reserve0, reserve1) = (_reserve0, _reserve1);
        if (feeOn) kLast = uint(_reserve0).mul(_reserve1);
        aggregateFeeVote = FeeVoting.add(aggregateFeeVote, deltaFeeVote);
    }

    function _initializeTick(int16 tickIndex) private {
        if (tickInfos[tickIndex].growthOutside._x == 0) {
            // by convention, we assume that all growth before tick was initialized happened _below_ a tick
            if (tickIndex <= currentTick) {
                tickInfos[tickIndex] = TickInfo({
                    secondsGrowthOutside: uint32(now % 2**32),
                    growthOutside: getG()
                });
            } else {
                tickInfos[tickIndex] = TickInfo({
                    secondsGrowthOutside: 0,
                    growthOutside: FixedPoint.encode(1)
                });
            }
        }
    }

    // helper functions for getting/setting position structs
    function getPositionKey(address owner, int16 lowerTick, int16 upperTick) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner, lowerTick, upperTick));
    }
    function getPosition(address owner, int16 lowerTick, int16 upperTick)
        private
        view
        returns (Position storage position)
    {
        position = positions[getPositionKey(owner, lowerTick, upperTick)];
    }
    function setPosition(address owner, int16 lowerTick, int16 upperTick, Position memory position) private {
        positions[getPositionKey(owner, lowerTick, upperTick)] = position;
    }

    // add or remove a specified amount of virtual liquidity from a specified range, and/or change feeVote for that range
    // also sync a position and return accumulated fees from it to user as tokens
    // liquidityDelta is sqrt(xy), so does not incorporate fees
    function setPosition(int112 liquidityDelta, int16 lowerTick, int16 upperTick, uint16 feeVote) external override lock {
        int112 amount0;
        int112 amount1;
        FeeVoting.Aggregate memory deltaFeeVote;
        require(feeVote > MIN_FEEVOTE && feeVote < MAX_FEEVOTE, "UniswapV3: INVALID_FEE_VOTE");
        require(lowerTick < upperTick, "UniswapV3: BAD_TICKS");
        { // scope to help with compilation
        require(virtualSupply > 0, 'UniswapV3: NOT_INITIALIZED');
        Position storage position = getPosition(msg.sender, lowerTick, upperTick);
        // initialize tickInfos if they don't exist yet
        _initializeTick(lowerTick);
        _initializeTick(upperTick);
        // before moving on, rebate any collected fees to user
        // note that unlevered liquidity wrapper can automatically recompound by setting liquidityDelta to their accumulated fees
        FixedPoint.uq112x112 memory growthInside = getGrowthInside(lowerTick, upperTick);
        { // scope to help with compilation
        int112 feeLiquidity = growthInside.smul112(int112(position.lastNormalizedLiquidity)) - int112(position.liquidity);
        (amount0, amount1) = getBalancesAtPrice(-feeLiquidity, FixedPoint.encode(reserve1).div(reserve0));
        }
        // update position
        FeeVoting.Aggregate memory oldFeeVote = FeeVoting.totalFeeVote(position);
        Position memory newPosition = Position({
            liquidity: position.liquidity.add(liquidityDelta),
            lastNormalizedLiquidity: growthInside.reciprocal().mul112(position.liquidity.add(liquidityDelta)).decode(),
            feeVote: feeVote
        });
        setPosition(msg.sender, lowerTick, upperTick, newPosition);
        deltaFeeVote = FeeVoting.sub(FeeVoting.totalFeeVote(newPosition), oldFeeVote);
        }
        // calculate how much the newly added/removed shares are worth at lower ticks and upper ticks
        (int112 lowerToken0Balance, int112 lowerToken1Balance) = getBalancesAtTick(liquidityDelta, lowerTick);
        (int112 upperToken0Balance, int112 upperToken1Balance) = getBalancesAtTick(liquidityDelta, upperTick);
        // update token0 deltas
        deltas[lowerTick] = deltas[lowerTick].add(lowerToken0Balance);
        deltas[upperTick] = deltas[upperTick].sub(upperToken0Balance);
        // update fee votes
        deltaFeeVotes[lowerTick] = FeeVoting.add(deltaFeeVotes[lowerTick], deltaFeeVote);
        deltaFeeVotes[upperTick] = FeeVoting.sub(deltaFeeVotes[upperTick], deltaFeeVote);
        if (currentTick < lowerTick) {
            amount1 = amount1.add(upperToken1Balance.sub(lowerToken1Balance));
        } else if (currentTick < upperTick) {
            (int112 virtualAmount0, int112 virtualAmount1) = updateVirtualLiquidity(liquidityDelta, deltaFeeVote);
            amount0 = amount0.add(virtualAmount0.sub(upperToken0Balance));
            amount1 = amount1.add(virtualAmount1.sub(lowerToken1Balance));
        } else {
            amount0 = amount0.add(lowerToken0Balance.sub(upperToken0Balance));
        }
        if (amount0 >= 0) {
            TransferHelper.safeTransferFrom(token0, msg.sender, address(this), uint112(amount0));
        } else {
            TransferHelper.safeTransfer(token0, msg.sender, uint112(-amount0));
        }
        if (amount1 >= 0) {
            TransferHelper.safeTransferFrom(token1, msg.sender, address(this), uint112(amount1));
        } else {
            TransferHelper.safeTransfer(token1, msg.sender, uint112(-amount1));
        }
        emit SetPosition(msg.sender, liquidityDelta, lowerTick, upperTick, feeVote);
    }

    // TODO: implement swap1for0, or integrate it into this
    function swap0for1(uint amountIn, address to, bytes calldata data) external lock {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();
        require(_reserve0 > 0 && _reserve1 > 0, "UniswapV3: NOT_INITIALIZED");
        (uint112 _oldReserve0, uint112 _oldReserve1) = (_reserve0, _reserve1);
        int16 _currentTick = currentTick;
        uint112 amountInLeft = uint112(amountIn);
        uint112 amountOut = 0;
        FeeVoting.Aggregate memory _aggregateFeeVote = aggregateFeeVote;
        while (amountInLeft > 0) {
            FixedPoint.uq112x112 memory price = TickMath.getPrice(_currentTick);
            // compute how much would need to be traded to get to the next tick down
            { // scope
            uint112 maxAmount = PriceMath.getTradeToRatio(_reserve0, _reserve1, FeeVoting.averageFee(aggregateFeeVote), price);
            uint112 amountInStep = (amountInLeft > maxAmount) ? maxAmount : amountInLeft;
            // execute the sell of amountToTrade
            uint112 adjustedAmountToTrade = amountInStep * (1000000 - FeeVoting.averageFee(_aggregateFeeVote)) / 1000000;
            uint112 amountOutStep = (adjustedAmountToTrade * _reserve1) / (_reserve0 + adjustedAmountToTrade);
            amountOut = amountOut.add(amountOutStep);
            _reserve0 = _reserve0.add(amountInStep);
            _reserve1 = _reserve1.sub(amountOutStep);
            amountInLeft = amountInLeft.sub(amountInStep);
            }
            if (amountInLeft > 0) { // shift past the tick
                TickInfo memory _oldTickInfo = tickInfos[_currentTick];
                if (_oldTickInfo.growthOutside._x == 0) {
                    _currentTick -= 1;
                    continue;
                }
                // TODO (eventually): batch all updates, including from mintFee
                bool feeOn = _mintFee(_reserve0, _reserve1);
                FixedPoint.uq112x112 memory _oldGrowthOutside = _oldTickInfo.growthOutside._x != 0 ?
                    _oldTickInfo.growthOutside :
                    FixedPoint.encode(uint112(1));
                // kick in/out liquidity
                int112 _delta = deltas[_currentTick] * -1; // * -1 because we're crossing the tick from right to left 
                _reserve0 = _reserve0.add(_delta);
                _reserve1 = _reserve1.add(price.smul112(_delta));
                virtualSupply = virtualSupply.add(int112(int(virtualSupply) * int(_delta) / int(_reserve0)));
                // kick in/out fee votes
                // sub because we're crossing the tick from right to left
                _aggregateFeeVote = FeeVoting.sub(_aggregateFeeVote, deltaFeeVotes[_currentTick]);
                // update tick info
                tickInfos[_currentTick] = TickInfo({
                    // overflow is desired
                    secondsGrowthOutside: uint32(block.timestamp % 2**32) - _oldTickInfo.secondsGrowthOutside,
                    growthOutside: getG().uqdiv112(_oldGrowthOutside)
                });
                _currentTick -= 1;
                if (feeOn) kLast = uint(_reserve0).mul(_reserve1);
            }
        }
        currentTick = _currentTick;
        // TODO: record new fees or something?
        emit Shift(_currentTick);
        TransferHelper.safeTransfer(token1, msg.sender, amountOut);
        if (data.length > 0) IUniswapV3Callee(to).uniswapV3Call(msg.sender, 0, amountOut, data);
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amountIn);
        _update(_oldReserve0, _oldReserve1, _reserve0, _reserve1);
        emit Swap(msg.sender, false, amountIn, amountOut, to);
    }
}