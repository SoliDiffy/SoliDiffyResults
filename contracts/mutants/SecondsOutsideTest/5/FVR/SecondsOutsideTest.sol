// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '../libraries/SecondsOutside.sol';

contract SecondsOutsideTest {
    using SecondsOutside for mapping(int24 => uint256);

    mapping(int24 => uint256) public secondsOutside;

    function initialize(
        int24 tick,
        int24 tickCurrent,
        int24 tickSpacing,
        uint32 time
    ) public {
        secondsOutside.initialize(tick, tickCurrent, tickSpacing, time);
    }

    function cross(
        int24 tick,
        int24 tickSpacing,
        uint32 time
    ) public {
        secondsOutside.cross(tick, tickSpacing, time);
    }

    function clear(int24 tick, int24 tickSpacing) public {
        secondsOutside.clear(tick, tickSpacing);
    }

    function get(int24 tick, int24 tickSpacing) public view returns (uint32) {
        return secondsOutside.get(tick, tickSpacing);
    }

    function secondsInside(
        int24 tickLower,
        int24 tickUpper,
        int24 tickCurrent,
        int24 tickSpacing,
        uint32 time
    ) public view returns (uint32) {
        return secondsOutside.secondsInside(tickLower, tickUpper, tickCurrent, tickSpacing, time);
    }
}
