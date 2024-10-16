// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;
pragma abicoder v2;

import './OracleTest.sol';

contract OracleEchidnaTest {
    OracleTest private oracle;

    bool initialized;
    uint32 timePassed;

    constructor() {
        oracle = new OracleTest();
    }

    function initialize(
        uint32 time,
        int24 tick,
        uint128 liquidity
    ) external {
        oracle.initialize(OracleTest.InitializeParams({time: time, tick: tick, liquidity: liquidity}));
        initialized = true;
    }

    function limitTimePassed(uint32 by) private {
        require(timePassed + by >= timePassed);
        timePassed += by;
    }

    function advanceTime(uint32 by) public {
        limitTimePassed(by);
        oracle.advanceTime(by);
    }

    // write an observation, then change tick and liquidity
    function update(
        uint32 advanceTimeBy,
        int24 tick,
        uint128 liquidity
    ) external {
        limitTimePassed(advanceTimeBy);
        oracle.update(OracleTest.UpdateParams({advanceTimeBy: advanceTimeBy, tick: tick, liquidity: liquidity}));
    }

    function grow(uint16 target) external {
        oracle.grow(target);
    }

    // private for now since it causes the test to run for too long
    function checkTimeWeightedResultAssertions(uint32 secondsAgo0, uint32 secondsAgo1) private view {
        require(secondsAgo0 != secondsAgo1);
        if (secondsAgo0 > secondsAgo1) (secondsAgo0, secondsAgo1) = (secondsAgo1, secondsAgo0);

        uint32 timeElapsed = secondsAgo1 - secondsAgo0;

        (int56 tickCumulative0, uint160 liquidityCumulative0) = oracle.scry(secondsAgo0);
        (int56 tickCumulative1, uint160 liquidityCumulative1) = oracle.scry(secondsAgo1);
        int56 timeWeightedTick = (tickCumulative1 - tickCumulative0) / timeElapsed;
        uint160 timeWeightedLiquidity = (liquidityCumulative1 - liquidityCumulative0) / timeElapsed;
        assert(timeWeightedLiquidity <= type(uint128).max);
        assert(timeWeightedTick <= type(int24).max);
        assert(timeWeightedTick >= type(int24).min);
    }

    function echidna_indexAlwaysLtCardinality() external view returns (bool) {
        return oracle.index() < oracle.cardinality() || !initialized;
    }

    function echidna_cardinalityAlwaysLteTarget() external view returns (bool) {
        return oracle.cardinality() <= oracle.target();
    }

    // todo: check we can always scry up to oldest observation if initialized
}